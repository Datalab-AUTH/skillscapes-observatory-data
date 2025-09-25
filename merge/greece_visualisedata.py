# greece_visualise_geo_labels.py
# Geo-centric visuals from merged_by_geo_greek_stacked.csv (STACKED)
# - Everything keyed by geo+year (labels are NOT used to group)
# - Bar charts (top/bottom) with per-geo nuts_label variants annotated
# - Optional choropleth (if you provide a NUTS shapefile)
#
# Run:
#   python greece_visualise_geo_labels.py [path\to\merged_by_geo_greek_stacked.csv]
#
# Optional env vars:
#   GREECE_STACKED_PATH   -> CSV path (defaults to ./merged_by_geo_greek_stacked.csv)
#   NUTS_SHAPE_PATH       -> Path to NUTS GeoPackage/Shapefile (e.g. NUTS_RG_01M_2021_4326.gpkg)
#   NUTS_SHAPE_LAYER      -> Layer name for GPKG (e.g. "NUTS_RG_01M_2021_4326")
#
# Outputs go to ./figs_geo_labels/

import os, sys, math
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

CSV_PATH = os.environ.get("GREECE_STACKED_PATH", "merged_data/merged_by_geo_greek_stacked.csv")
SHAPE_PATH = os.environ.get("NUTS_SHAPE_PATH", "")
SHAPE_LAYER = os.environ.get("NUTS_SHAPE_LAYER", None)
OUT_DIR = "figs_geo_labels"
os.makedirs(OUT_DIR, exist_ok=True)

# How many label variants to print next to each geo on the chart
MAX_LABELS_PER_GEO = 3  # keep it readable; the full set is saved to CSV

# Source map (as in your merge)
METRIC_SOURCE = {
    "Hotel_Arrivals_Total": "greek_tourism_Arrivals",
    "Hotel_Stays_Total":    "greek_tourism_Stays",
    "Hotel_Occupancy":      "greek_tourism_Stays",
    "Turnover_Accomodation":"greek_tourism_Turnover",
    "Turnover_Catering":    "greek_tourism_Turnover",
    "GDP":                  "greek_tourism_GDP",
}

FOCUS_METRICS = [
    "Hotel_Arrivals_Total",
    "Hotel_Stays_Total",
    "Turnover_Accomodation",
    "GDP",
]

DEFAULT_LEVEL = 2  # NUTS2 visuals by default


# ---------------------- helpers ----------------------
def infer_level_from_geo(geo: str):
    """
    Infer NUTS level from EL/GR code length:
      EL (2)->0, ELx(3)->1, ELxx(4)->2, ELxxx(5)->3
    """
    if not isinstance(geo, str):
        return math.nan
    L = len(geo.strip())
    return {2:0, 3:1, 4:2, 5:3}.get(L, math.nan)


def load_stacked(path: str) -> pd.DataFrame:
    df = pd.read_csv(path, encoding="utf-8-sig")
    need = {"geo","year","source"}
    miss = need - set(df.columns)
    if miss:
        raise ValueError(f"Missing required columns {miss} in {path}")

    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")
    if "nuts_level" not in df.columns:
        df["nuts_level"] = df["geo"].map(infer_level_from_geo)
    else:
        df["nuts_level"] = pd.to_numeric(df["nuts_level"], errors="coerce")
        m = df["nuts_level"].isna()
        if m.any():
            df.loc[m, "nuts_level"] = df.loc[m, "geo"].map(infer_level_from_geo)
    return df


def coalesce_by_geo_year(df: pd.DataFrame, metric: str) -> pd.DataFrame:
    """
    Filter to the metric's source then collapse to one value per (geo,year).
    If multiple distinct values exist, take the mean and write a clash CSV.
    """
    src = METRIC_SOURCE[metric]
    sub = df[df["source"].eq(src)][["geo","year",metric]].copy()
    sub[metric] = pd.to_numeric(sub[metric], errors="coerce")

    # detect clashes
    nuniq = (sub.groupby(["geo","year"])[metric]
                .nunique(dropna=True)
                .reset_index(name="nuniq"))
    bad = nuniq[nuniq["nuniq"] > 1]
    if not bad.empty:
        out = sub.merge(bad[["geo","year"]], on=["geo","year"]).sort_values(["geo","year"])
        path = os.path.join(OUT_DIR, f"clashes_{metric}.csv")
        out.to_csv(path, index=False, encoding="utf-8-sig")
        print(f"[warn] {len(bad)} (geo,year) have multiple {metric} values. Averaging. -> {path}")

    agg = sub.groupby(["geo","year"], as_index=False)[metric].mean()
    return agg


def label_variants_for_geos(df: pd.DataFrame, geos: list[str]) -> pd.DataFrame:
    """
    For the provided geos, collect all distinct nuts_label variants seen in the STACKED file.
    Returns: geo | nuts_labels (list) | n_variants
    """
    # note: include all sources, since label is meta
    sub = df[df["geo"].isin(geos)].copy()
    # keep as strings, drop NA/empty, deduplicate per geo
    sub["nuts_label"] = sub["nuts_label"].astype("string")
    sub = sub.dropna(subset=["nuts_label"])
    sub["nuts_label"] = sub["nuts_label"].str.strip()
    sub = sub[sub["nuts_label"] != ""]
    out = (sub.groupby("geo")["nuts_label"]
              .agg(lambda s: sorted(pd.unique(s)))
              .reset_index())
    out["n_variants"] = out["nuts_label"].apply(len)
    return out


def nice_save(fig, name):
    path = os.path.join(OUT_DIR, name)
    fig.tight_layout()
    fig.savefig(path, dpi=150, bbox_inches="tight")
    print("Saved:", path)
    plt.close(fig)


def latest_year_available(agg: pd.DataFrame) -> int:
    return int(agg["year"].max())


# ---------------------- visuals ----------------------
def bar_top_bottom_latest_with_labels(df: pd.DataFrame, metric: str, level: int = DEFAULT_LEVEL, k: int = 10):
    """
    Two bar charts (Top-K & Bottom-K) for the latest year at the requested NUTS level.
    Each bar is annotated with the nuts_label variants seen for that geo in the data.
    """
    agg = coalesce_by_geo_year(df, metric)
    yr = latest_year_available(agg)
    snap = agg[agg["year"].eq(yr)].dropna(subset=[metric]).copy()

    # keep requested level by geo code length
    snap["lvl"] = snap["geo"].map(infer_level_from_geo)
    snap = snap[snap["lvl"].eq(level)]
    if snap.empty:
        print(f"[skip] No data for {metric} at level {level}")
        return

    # build label variants dict for the geos we might plot
    cand_geos = snap["geo"].tolist()
    lab = label_variants_for_geos(df, cand_geos)
    labels_map = dict(zip(lab["geo"], lab["nuts_label"]))
    nvar_map   = dict(zip(lab["geo"], lab["n_variants"]))

    def _pretty_variants(geo):
        labels = labels_map.get(geo, [])
        if not labels:
            return "—"
        # show up to MAX_LABELS_PER_GEO, indicate if more
        shown = labels[:MAX_LABELS_PER_GEO]
        extra = len(labels) - len(shown)
        s = " | ".join(shown)
        if extra > 0:
            s += f"  (+{extra})"
        return s

    def _plot_one(ax, frame, title):
        # horizontal bars
        ax.barh(frame["geo"], frame[metric])
        ax.invert_yaxis()
        ax.set_title(title)
        ax.set_xlabel(metric.replace("_"," "))

        # annotate variants to the right of each bar
        # compute small offset: a few percent of axis span
        x0, x1 = ax.get_xlim()
        offset = (x1 - x0) * 0.01
        for y, (geo, val) in enumerate(zip(frame["geo"], frame[metric])):
            txt = _pretty_variants(geo)
            ax.text(val + offset, y, txt, va="center", fontsize=8)
        # extend xlim so text isn't cut off
        ax.set_xlim(x0, x1 + (x1 - x0) * 0.6)

        # lighter grid for readability
        ax.grid(axis="x", alpha=0.3)

    top = snap.nlargest(k, metric)
    bot = snap.nsmallest(k, metric)

    fig, axes = plt.subplots(1, 2, figsize=(18, 7), sharey=False)

    # left: top-K
    _plot_one(axes[0], top, f"Top {k} geos — {metric} ({yr}) @ NUTS {level}")
    axes[0].tick_params(axis="y", labelleft=True)

    # right: bottom-K
    _plot_one(axes[1], bot, f"Bottom {k} geos — {metric} ({yr}) @ NUTS {level}")
    axes[1].tick_params(axis="y", labelleft=True)  # ensure labels are shown

    nice_save(fig, f"geo_bar_topbottom_withlabels_{metric}_L{level}_{yr}.png")

    # also write a full CSV of variants for all geos at this level for reference
    full = label_variants_for_geos(df[df["geo"].map(infer_level_from_geo).eq(level)], snap["geo"].unique())
    full.rename(columns={"nuts_label":"nuts_labels"}, inplace=True)
    full["nuts_labels"] = full["nuts_labels"].apply(lambda lst: " | ".join(lst))
    full_path = os.path.join(OUT_DIR, f"geo_label_variants_level{level}.csv")
    full.sort_values(["n_variants","geo"], ascending=[False, True]).to_csv(full_path, index=False, encoding="utf-8-sig")
    print(f"Geo -> nuts_label variants CSV -> {full_path}")


def choropleth_latest(df: pd.DataFrame, metric: str, level: int = DEFAULT_LEVEL):
    """Optional choropleth (only if you provide a NUTS shapefile)."""
    try:
        import geopandas as gpd
    except Exception:
        print("[skip] geopandas not available; choropleth skipped.")
        return
    if not SHAPE_PATH or not os.path.exists(SHAPE_PATH):
        print("[skip] NUTS shapefile not provided; set NUTS_SHAPE_PATH to enable maps.")
        return

    agg = coalesce_by_geo_year(df, metric)
    yr = latest_year_available(agg)
    snap = agg[agg["year"].eq(yr)].dropna(subset=[metric]).copy()
    snap["lvl"] = snap["geo"].map(infer_level_from_geo)
    snap = snap[snap["lvl"].eq(level)]
    if snap.empty:
        print(f"[skip] choropleth: no data for {metric} at level {level}")
        return

    if SHAPE_PATH.lower().endswith(".gpkg"):
        nuts = (gpd.read_file(SHAPE_PATH, layer=SHAPE_LAYER)
                if SHAPE_LAYER else gpd.read_file(SHAPE_PATH))
    else:
        nuts = gpd.read_file(SHAPE_PATH)

    id_col = "NUTS_ID" if "NUTS_ID" in nuts.columns else ("nuts_id" if "nuts_id" in nuts.columns else None)
    if id_col is None:
        raise ValueError("Could not find NUTS_ID column in shapefile.")
    lvl_col = "LEVL_CODE" if "LEVL_CODE" in nuts.columns else ("levl_code" if "levl_code" in nuts.columns else None)
    cntr_col= "CNTR_CODE" if "CNTR_CODE" in nuts.columns else ("cntr_code" if "cntr_code" in nuts.columns else None)

    if lvl_col:
        nuts = nuts[nuts[lvl_col].astype(int) == level]
    if cntr_col:
        nuts = nuts[nuts[cntr_col].astype(str).str.upper().eq("EL")]

    nuts = nuts[[id_col, "geometry"]].rename(columns={id_col:"geo"})
    gdf = nuts.merge(snap[["geo", metric]], on="geo", how="left")

    fig, ax = plt.subplots(figsize=(8, 10))
    gdf.plot(column=metric, ax=ax, legend=True, missing_kwds={"color":"lightgrey"})
    ax.set_title(f"{metric} — {yr} (NUTS {level})")
    ax.axis("off")
    nice_save(fig, f"map_{metric}_L{level}_{yr}.png")


# ---------------------- main ----------------------
def main():
    path = CSV_PATH if len(sys.argv) < 2 else sys.argv[1]
    print("Reading:", path)
    df = load_stacked(path)

    # quick info
    print(f"Distinct geos: {df['geo'].nunique()}")
    years = sorted([int(y) for y in df['year'].dropna().unique()])
    if years:
        print(f"Years: {years[0]}…{years[-1]}")

    # bar charts (top/bottom) with labels
    for m in FOCUS_METRICS:
        bar_top_bottom_latest_with_labels(df, m, level=DEFAULT_LEVEL, k=10)

    # OPTIONAL: one or two choropleths
    for m in ["Hotel_Arrivals_Total", "GDP"]:
        choropleth_latest(df, m, level=DEFAULT_LEVEL)

    print("All figures in:", os.path.abspath(OUT_DIR))

if __name__ == "__main__":
    main()


# ====================== NUTS-3 EXTENSIONS (append below) ======================

LEVEL_3 = 3  # NUTS3

def sparklines_top_geos(df: pd.DataFrame, metric: str, level: int = LEVEL_3, top_n: int = 12):
    """
    Small-multiples: top-N geos at NUTS3 by latest-year value, each with a mini trend line.
    Uses nuts_label variants as subtitle on each panel (first few only).
    """
    agg = coalesce_by_geo_year(df, metric)
    if agg.empty:
        print(f"[skip] No data for {metric}")
        return

    latest = int(agg["year"].max())
    snap = agg[agg["year"].eq(latest)].dropna(subset=[metric]).copy()
    snap["lvl"] = snap["geo"].map(infer_level_from_geo)
    snap = snap[snap["lvl"].eq(level)]
    if snap.empty:
        print(f"[skip] No {metric} data at NUTS {level}")
        return

    # pick top-N geos by latest value
    top_geos = snap.nlargest(top_n, metric)["geo"].tolist()

    # bring in label variants for subtitle
    labs = label_variants_for_geos(df, top_geos)
    labs_map = dict(zip(labs["geo"], labs["nuts_label"]))

    # long panel data for the chosen geos
    panel = agg[agg["geo"].isin(top_geos)].copy().sort_values(["geo", "year"])

    # figure grid
    n = len(top_geos)
    cols = 4
    rows = int(np.ceil(n / cols))
    fig, axes = plt.subplots(rows, cols, figsize=(4.2*cols, 3.2*rows), sharey=False)
    axes = np.array(axes).reshape(rows, cols)

    # nice y range per metric
    panel[metric] = pd.to_numeric(panel[metric], errors="coerce")

    for i, geo in enumerate(top_geos):
        r, c = divmod(i, cols)
        ax = axes[r, c]
        g = panel[panel["geo"] == geo]
        ax.plot(g["year"].astype(int), g[metric], marker="o")
        ax.grid(True, alpha=0.3)
        ax.set_title(geo, fontsize=10, loc="left", pad=6)

        # subtitle with a few label variants
        variants = labs_map.get(geo, [])
        if variants:
            sub = " | ".join(variants[:MAX_LABELS_PER_GEO])
            more = len(variants) - min(len(variants), MAX_LABELS_PER_GEO)
            if more > 0:
                sub += f"  (+{more})"
            ax.text(0.02, 0.92, sub, transform=ax.transAxes, fontsize=8, va="top", ha="left")

        # pretty axes
        ax.tick_params(labelsize=9)
        ax.set_xlabel("Year", fontsize=9)
        ax.set_ylabel(metric.replace("_", " "), fontsize=9)

    # hide any empty cells
    for j in range(n, rows*cols):
        r, c = divmod(j, cols)
        axes[r, c].axis("off")

    fig.suptitle(f"Top {top_n} geos — {metric} trends (latest={latest}) @ NUTS {level}", fontsize=14)
    nice_save(fig, f"sparklines_top{top_n}_{metric}_L{level}.png")

def run_nuts3_visuals(df: pd.DataFrame):
    print("\n--- NUTS-3 visuals ---")
    for m in ["Hotel_Arrivals_Total", "Hotel_Stays_Total", "Turnover_Accomodation", "GDP"]:
        # Top/Bottom bars with label variants at NUTS-3
        bar_top_bottom_latest_with_labels(df, m, level=LEVEL_3, k=15)
        # Sparkline dashboard for top regions (compact)
        sparklines_top_geos(df, m, level=LEVEL_3, top_n=12)
        # Optional choropleths (if shapefile vars provided)
        choropleth_latest(df, m, level=LEVEL_3)

# Hook into existing main
if __name__ == "__main__":
    # Your existing main() already ran. If you want NUTS-3 to run automatically too,
    # re-load the stacked file and call the new driver:
    try:
        df__nuts3 = load_stacked(CSV_PATH if len(sys.argv) < 2 else sys.argv[1])
        run_nuts3_visuals(df__nuts3)
        print("NUTS-3 figures saved to:", os.path.abspath(OUT_DIR))
    except Exception as _e:
        print("[warn] NUTS-3 visuals skipped due to error:", _e)

