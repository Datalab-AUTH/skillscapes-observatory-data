#!/usr/bin/env python3
"""
Merge ALL CSVs from ../data using the STACKED methodology (no WIDE),
with robust preprocessing and a full data-quality report.

Inclusion rule: every *.csv under ../data (both greek_* and non-greek).
Exclusion rule: none (only skips files that cannot be read).

Outputs:
  1) merged_data/merged_by_geo_all_stacked.csv
  2) _dq_all/DATA_QUALITY_REPORT.md
  3) _dq_all/*.csv            -> per-file missingness, post-merge diagnostics, label variants

Notes:
- Standardizes columns: geo, year, nuts_label, nuts_level
- Keeps per-file rows as-is (no per-file dedup of distinct rows)
- Adds 'source' = file stem
- Treats helper columns like the other scripts (no nuts_level inference into the dataset)
"""

from pathlib import Path
import sys
import pandas as pd
import unicodedata
import re
from datetime import datetime, timezone
from collections import Counter

# -------- Paths --------
if "__file__" in globals():
    HERE = Path(__file__).resolve().parent
else:
    HERE = Path.cwd()

DATA_DIR = (HERE / ".." / "data").resolve()
OUT_DIR = HERE

OUT_STACKED = OUT_DIR / "merged_data/merged_by_geo_all_stacked.csv"
LOG_FILE = OUT_DIR / "logs/merge_log_all.txt"

DQ_DIR = OUT_DIR / "_dq_all"
DQ_DIR.mkdir(parents=True, exist_ok=True)

# -------- Helpers: text normalization --------
def strip_accents(text: str) -> str:
    if not isinstance(text, str):
        return text
    nfkd = unicodedata.normalize("NFKD", text)
    return "".join(ch for ch in nfkd if not unicodedata.combining(ch))

def normalize_geo(val):
    """
    Canonicalize 'geo':
      - If it looks like a NUTS-like code (two letters + alphanum), return uppercase, no spaces.
      - Else: accent-strip, single-space, casefold for robust name matching.
    Handles EL/GR prefixed Greek codes and all EU NUTS-like codes (DE21, ES300, etc.).
    """
    if pd.isna(val):
        return pd.NA
    s = str(val).strip()
    s = unicodedata.normalize("NFKC", s)
    # NUTS-ish?
    if re.fullmatch(r"[A-Za-z]{2}\s*[\dA-Za-z]+", s):
        return re.sub(r"\s+", "", s).upper()
    # Name-like
    s = strip_accents(s)
    s = re.sub(r"\s+", " ", s).casefold()
    return s

def find_col(df, wanted):
    """Case-insensitive column finder (exact first, then partial)."""
    cols_lower = {c.lower(): c for c in df.columns}
    if wanted.lower() in cols_lower:
        return cols_lower[wanted.lower()]
    for c in df.columns:
        if c.lower() == wanted.lower():
            return c
    return None

def _infer_level_from_geo(geo: str):
    """NUTS code length heuristic: AA (2)->0, AAx(3)->1, AAxx(4)->2, AAxxx(5)->3.
    NOTE: Used only for label-variant exports (same as other scripts), not to fill nuts_level in data.
    """
    if not isinstance(geo, str):
        return pd.NA
    g = geo.strip()
    return {2:0, 3:1, 4:2, 5:3}.get(len(g), pd.NA)

# --- schema helpers ----------------------------------------------------------
def enforce_schema(df: pd.DataFrame) -> pd.DataFrame:
    # ensure required columns exist
    for c in ["geo", "year", "nuts_label", "nuts_level"]:
        if c not in df.columns:
            df[c] = pd.NA

    # text columns as pandas StringDtype
    for c in ["geo", "nuts_label"]:
        df[c] = (df[c]
                 .astype("string")
                 .str.normalize("NFKC")
                 .str.strip()
                 .replace("", pd.NA))

    # year: keep only 4-digit tokens -> Int64 (nullable int)
    df["year"] = (df["year"]
                  .astype("string")
                  .str.strip()
                  .where(df["year"].astype("string").str.fullmatch(r"\d{4}"), pd.NA)
                  .astype("Int64"))

    # nuts_level: numeric -> Int64 (nullable int)
    df["nuts_level"] = pd.to_numeric(df["nuts_level"], errors="coerce").astype("Int64")

    return df

# -------- DQ helpers --------
def profile_single_file(df: pd.DataFrame, file_stem: str, key=("geo","year")):
    """Return dict + write per-file missingness and duplicate-key sample."""
    report = {}
    report["rows"] = len(df)
    report["cols"] = df.shape[1]
    report["columns"] = list(df.columns)

    # year sanity
    if "year" in df.columns:
        y = pd.to_numeric(df["year"], errors="coerce")
        report["year_min"] = int(y.min()) if y.notna().any() else None
        report["year_max"] = int(y.max()) if y.notna().any() else None
        bad_year_mask = ~df["year"].astype(str).str.fullmatch(r"\d{4}")
        report["bad_year_values"] = sorted(map(str, pd.unique(df.loc[bad_year_mask,"year"]))) if bad_year_mask.any() else []

    # missingness
    miss = df.isna().mean().sort_values(ascending=False)
    miss.to_csv(DQ_DIR / f"{file_stem}__missingness.csv", encoding="utf-8-sig")
    report["missing_top5"] = miss.head(5).to_dict()

    # duplicate keys (geo,year) just for visibility (we do NOT collapse in STACKED)
    if set(key).issubset(df.columns):
        dupe_key = df.duplicated(subset=list(key)).sum()
        report["duplicate_key_rows"] = int(dupe_key)
        dups = df[df.duplicated(subset=list(key), keep=False)].sort_values(list(key))
        if not dups.empty:
            dups.head(200).to_csv(DQ_DIR / f"{file_stem}__duplicate_keys_sample.csv", index=False, encoding="utf-8-sig")
    else:
        report["duplicate_key_rows"] = None

    # duplicate full rows (informational)
    report["duplicate_full_rows"] = int(df.duplicated().sum())

    # plausibility: common non-negatives
    numeric_cols = df.select_dtypes(include="number").columns.tolist()
    plaus = []
    for c in numeric_cols:
        name = c.lower()
        must_be_nonneg = any(k in name for k in ["total","beds","turnover","arrivals","stays","gva","gdp","gfcf","employment","unemployment"])
        if must_be_nonneg:
            s = pd.to_numeric(df[c], errors="coerce")
            bad = s.dropna()[s.dropna() < 0]
            if not bad.empty:
                plaus.append((c, int(bad.count())))
    report["non_negative_violations"] = dict(plaus)

    report["dtypes"] = df.dtypes.astype(str).to_dict()
    return report

def profile_post_stack(stacked: pd.DataFrame):
    """Global diagnostics on the final STACKED frame."""
    rep = {"rows": len(stacked), "cols": stacked.shape[1]}
    # missingness
    miss = stacked.isna().mean().sort_values(ascending=False)
    miss.to_csv(DQ_DIR / "post__missingness.csv", encoding="utf-8-sig")
    rep["missing_top10"] = miss.head(10).to_dict()

    # coverage by nuts_level & year (if present)
    if "nuts_level" in stacked.columns and "year" in stacked.columns:
        cov = (stacked
               .groupby(["nuts_level","year"], dropna=False)
               .size()
               .rename("rows")
               .reset_index())
        cov.to_csv(DQ_DIR / "post__coverage_by_level_year.csv", index=False, encoding="utf-8-sig")

    # outlier scan across numeric columns (rate only; samples optional)
    def iqr_outlier_flags(s: pd.Series):
        x = pd.to_numeric(s, errors="coerce").dropna()
        if x.empty:
            return pd.Series([False] * len(s), index=s.index)
        q1, q3 = x.quantile([0.25, 0.75])
        iqr = q3 - q1
        lo, hi = q1 - 1.5*iqr, q3 + 1.5*iqr
        mask = (pd.to_numeric(s, errors="coerce") < lo) | (pd.to_numeric(s, errors="coerce") > hi)
        return mask.fillna(False)

    num_cols = stacked.select_dtypes(include="number").columns
    outlier_rates = {}
    for c in num_cols:
        mask = iqr_outlier_flags(stacked[c])
        rate = float(mask.mean())
        if rate > 0:
            outlier_rates[c] = round(rate, 4)
            if rate > 0.05:
                stacked.loc[mask, ["geo","year",c]].head(200).to_csv(
                    DQ_DIR / f"post__outliers__{c}.csv", index=False, encoding="utf-8-sig"
                )
    rep["outlier_rates"] = outlier_rates
    return rep

def write_markdown_report(pre_reports: dict, post_report: dict, out_path: Path):
    lines = []
    lines.append(f"# Data Quality Report (ALL → STACKED)")
    ts = datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    lines.append(f"_Generated: {ts}_")
    lines.append("")
    lines.append("## Pre-merge (per file)")
    for stem, rpt in pre_reports.items():
        lines.append(f"### {stem}")
        lines.append(f"- Rows: **{rpt['rows']}**, Cols: **{rpt['cols']}**")
        if "year_min" in rpt:
            lines.append(f"- Year range: **{rpt.get('year_min')} – {rpt.get('year_max')}**"
                         f"{' (bad values present)' if rpt.get('bad_year_values') else ''}")
            if rpt.get("bad_year_values"):
                lines.append(f"  - Bad year tokens: `{rpt['bad_year_values']}`")
        lines.append(f"- Duplicate full rows: **{rpt['duplicate_full_rows']}**")
        if rpt.get("duplicate_key_rows") is not None:
            lines.append(f"- Duplicate (geo,year) rows: **{rpt['duplicate_key_rows']}**"
                         f"{' (sample CSV saved)' if rpt['duplicate_key_rows'] else ''}")
        if rpt.get("non_negative_violations"):
            lines.append(f"- Non-negative violations: {rpt['non_negative_violations']}")
        if rpt.get("missing_top5"):
            miss5 = ', '.join([f"{k}: {v:.0%}" for k,v in rpt["missing_top5"].items()])
            lines.append(f"- Top missingness: {miss5}")
        lines.append(f"- Missingness CSV: `_dq_all/{stem}__missingness.csv`")
        lines.append("")
    lines.append("## Post-merge (STACKED)")
    lines.append(f"- Rows: **{post_report.get('rows')}**, Cols: **{post_report.get('cols')}**")
    if post_report.get("missing_top10"):
        miss10 = ', '.join([f"{k}: {v:.0%}" for k,v in post_report["missing_top10"].items()])
        lines.append(f"- Top missing columns: {miss10}")
        lines.append(f"- Full CSV: `_dq_all/post__missingness.csv`")
    if post_report.get("outlier_rates"):
        big = {k:v for k,v in post_report["outlier_rates"].items() if v > 0.05}
        if big:
            items = ', '.join([f"{k} (~{v:.1%})" for k,v in big.items()])
            lines.append(f"- Notable outlier rates (>5%): {items} (samples under `_dq_all/post__outliers__*.csv`)")
    out_path.write_text("\n".join(lines), encoding="utf-8")

# ---------- Label variants per geo, per NUTS level (from STACKED) -----------
def write_geo_label_variants_from_stacked(stacked: pd.DataFrame):
    s = stacked.copy()
    s["nuts_level"] = pd.to_numeric(s.get("nuts_level"), errors="coerce")
    nl_missing = s["nuts_level"].isna()
    # For label-variant reporting only (same as other scripts), infer level when missing:
    if nl_missing.any():
        s.loc[nl_missing, "nuts_level"] = s.loc[nl_missing, "geo"].map(_infer_level_from_geo)

    base = s[["geo", "nuts_level", "nuts_label"]].dropna(subset=["geo"]).copy()

    # all geo/level pairs present (so geos with no labels aren't dropped)
    geo_level_all = (
        base[["geo", "nuts_level"]]
        .dropna(subset=["nuts_level"])
        .drop_duplicates()
    )

    def _collect(series):
        vals = (series.astype("string").dropna().str.strip())
        vals = vals[vals != ""]
        return sorted(pd.unique(vals))

    variants = (
        base.groupby(["geo", "nuts_level"], dropna=False)["nuts_label"]
            .agg(_collect)
            .reset_index()
    )

    variants = geo_level_all.merge(variants, on=["geo", "nuts_level"], how="left")
    variants["nuts_label"] = variants["nuts_label"].apply(lambda v: v if isinstance(v, list) else [])
    variants["n_variants"] = variants["nuts_label"].apply(len)
    variants["labels_joined"] = variants["nuts_label"].apply(lambda lst: " | ".join(lst) if lst else "—")

    levels_present = (
        variants["nuts_level"].dropna().astype(int).sort_values().unique().tolist()
    )
    for lev in levels_present:
        out_df = (
            variants.loc[variants["nuts_level"].astype(int).eq(lev),
                         ["geo", "nuts_level", "n_variants", "labels_joined"]]
            .sort_values(["n_variants","geo"], ascending=[False, True])
            .reset_index(drop=True)
        )
        out_path = DQ_DIR / f"geo_labels_L{lev}.csv"
        out_df.to_csv(out_path, index=False, encoding="utf-8-sig")
        print(f"Geo→label variants (level {lev}) -> {out_path}")

    combined_path = DQ_DIR / "geo_labels_all_levels.csv"
    variants[["geo","nuts_level","n_variants","labels_joined"]].sort_values(
        ["nuts_level","n_variants","geo"], ascending=[True, False, True]
    ).to_csv(combined_path, index=False, encoding="utf-8-sig")
    print(f"Combined geo→label variants (all levels) -> {combined_path}")

# -------- Main --------
def main():
    try:
        import pandas as _p  # noqa
    except Exception:
        print("This script requires pandas. Install with: python -m pip install pandas")
        sys.exit(1)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    assert DATA_DIR.exists(), f"Data folder not found: {DATA_DIR}"

    # Collect ALL CSVs under ../data
    all_csvs = sorted(DATA_DIR.glob("*.csv"))
    if not all_csvs:
        raise SystemExit(f"No CSV files found in {DATA_DIR}")

    log_lines = []
    dfs_stacked = []
    pre_reports = {}

    # Robust encodings to try (Greek + Western Europe)
    ENCODINGS = ["utf-8-sig", "cp1253", "cp1252", "latin-1"]

    for fp in all_csvs:
        try:
            # --- robust read with encoding & delimiter sniffing ---
            last_err = None
            used_enc = None
            for enc in ENCODINGS:
                try:
                    raw = pd.read_csv(fp, encoding=enc, sep=None, engine="python")
                    used_enc = enc
                    break
                except Exception as e:
                    last_err = e
            else:
                raise last_err

            original_cols = list(raw.columns)
            df = raw.copy()

            # --- standardize keys (geo/year/nuts_*) ---
            # geo column
            geo_col = None
            for cand in ["geo", "region", "regional_unit", "regional unit", "perifereia",
                         "nomos", "area", "location", "nuts_id", "nuts", "NUTS_ID"]:
                geo_col = find_col(df, cand)
                if geo_col: break
            if not geo_col:
                raise ValueError(f"No 'geo' (or equivalent) column found. Columns: {list(raw.columns)}")
            if geo_col != "geo":
                df = df.rename(columns={geo_col: "geo"})
            df["geo"] = df["geo"].map(normalize_geo)

            # year column
            year_col = None
            for cand in ["year", "time", "yr", "year_int"]:
                year_col = find_col(df, cand)
                if year_col: break
            if not year_col:
                raise ValueError(f"No 'year' column found. Columns: {list(raw.columns)}")
            if year_col != "year":
                df = df.rename(columns={year_col: "year"})

            # enforce 4-digit years, drop bad rows
            bad_mask = ~df["year"].astype(str).str.fullmatch(r"\d{4}")
            if bad_mask.any():
                log_lines.append(f"[{fp.stem}] Non-4digit year values dropped: {df.loc[bad_mask, 'year'].unique().tolist()}")
            df = df[~bad_mask].copy()
            df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")

            # optional helpers
            nlabel = find_col(df, "nuts_label")
            if nlabel and nlabel != "nuts_label":
                df = df.rename(columns={nlabel: "nuts_label"})
            nlevel = find_col(df, "nuts_level")
            if nlevel and nlevel != "nuts_level":
                df = df.rename(columns={nlevel: "nuts_level"})

            # lock dtypes (same treatment as other scripts)
            df = enforce_schema(df)

            # drop rows missing keys
            df.columns = [c.strip() for c in df.columns]
            before = len(df)
            df = df.dropna(subset=["geo", "year"])
            after = len(df)
            if after < before:
                log_lines.append(f"[{fp.stem}] Dropped {before - after} rows with NA in geo/year.")

            # ---- PRE-MERGE DQ for this file ----
            pre_reports[fp.stem] = profile_single_file(df, fp.stem, key=("geo","year"))

            # STACKED (no per-file dedup of distinct rows); add source
            stacked_part = df.copy()
            stacked_part["source"] = fp.stem

            # Lead ordering for readability
            lead = ["geo","year","nuts_level","nuts_label","source"]
            other = [c for c in stacked_part.columns if c not in lead]
            stacked_part = stacked_part[lead + other]

            dfs_stacked.append(stacked_part)

            # log recap
            n_geos = stacked_part["geo"].nunique(dropna=True)
            n_years = stacked_part["year"].nunique(dropna=True)
            log_lines.append(
                f"Loaded: {fp.name} (enc={used_enc}) | rows={len(df)} | geos={n_geos}, years={n_years} | "
                f"orig_cols={original_cols}"
            )

        except Exception as e:
            log_lines.append(f"ERROR reading {fp.name}: {e}")

    if not dfs_stacked:
        raise SystemExit("No dataframes were successfully read. See merge_log_all.txt for details.")

    # -------- Build final STACKED from raw data --------
    stacked = pd.concat(dfs_stacked, ignore_index=True, sort=False)
    stacked = stacked.sort_values(["geo","year","source"], na_position="last").reset_index(drop=True)

    # --- Global dedup (same policy as other scripts) --------------------------
    # 1) Drop FULL-ROW exact duplicates (same values in every column)
    before_exact = len(stacked)
    stacked = stacked.drop_duplicates()
    dropped_exact = before_exact - len(stacked)

    # 2) Drop duplicates identical across everything EXCEPT 'source'
    cols_wo_source = [c for c in stacked.columns if c != "source"]
    before_semantic = len(stacked)
    stacked = stacked.drop_duplicates(subset=cols_wo_source, keep="first")
    dropped_semantic = before_semantic - len(stacked)

    # Final sort and write
    stacked = stacked.sort_values(["geo","year","source"], na_position="last").reset_index(drop=True)
    OUT_STACKED.parent.mkdir(parents=True, exist_ok=True)
    stacked.to_csv(OUT_STACKED, index=False, encoding="utf-8-sig")

    # -------- Quick exports from STACKED (helpers & labels) -------------------
    nuts_levels_df = (
        stacked[["nuts_level"]]
        .dropna()
        .drop_duplicates()
        .sort_values(by="nuts_level")
        .reset_index(drop=True)
    )
    nuts_levels_df.to_csv(DQ_DIR / "post__nuts_levels.csv", index=False, encoding="utf-8-sig")

    nuts_labels_geo_df = (
        stacked[["geo","nuts_level","nuts_label"]]
        .dropna(subset=["nuts_label"])
        .drop_duplicates()
        .sort_values(["geo","nuts_level","nuts_label"])
        .reset_index(drop=True)
    )
    nuts_labels_geo_df.to_csv(DQ_DIR / "post__nuts_labels.csv", index=False, encoding="utf-8-sig")

    nuts_labels_by_level_df = (
        stacked[["nuts_level","nuts_label"]]
        .dropna()
        .drop_duplicates()
        .sort_values(["nuts_level","nuts_label"])
        .reset_index(drop=True)
    )
    nuts_labels_by_level_df.to_csv(DQ_DIR / "post__nuts_labels_by_level.csv", index=False, encoding="utf-8-sig")

    # Per-level label variants (same behavior as other scripts)
    write_geo_label_variants_from_stacked(stacked)

    # -------- DQ report --------
    post_report = profile_post_stack(stacked)
    dq_report_path = DQ_DIR / "DATA_QUALITY_REPORT.md"
    write_markdown_report(pre_reports, post_report, dq_report_path)

    # -------- Log --------
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        for line in log_lines:
            f.write(line + "\n")
        f.write(
            f"\nSTACKED shape: {stacked.shape} -> {OUT_STACKED.name}"
            f"\nExact duplicates removed: {dropped_exact}"
            f"\nDuplicates removed ignoring only 'source': {dropped_semantic}"
            f"\nDQ report: {dq_report_path.name}\n"
        )

    print("Done.")
    print(f"  STACKED: {OUT_STACKED.name} Shape: {stacked.shape}")
    print(f"Details logged to: {LOG_FILE.name}")
    print(f"DQ report: {dq_report_path}")

if __name__ == "__main__":
    main()