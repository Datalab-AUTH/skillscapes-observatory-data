#!/usr/bin/env python3

#!/usr/bin/env python3

import pandas as pd
import re


def read_row_values_until_blank(df, row, start_col):
    """Read values from df[row, start_col:] until the first blank cell."""
    values = []
    for col in range(start_col, df.shape[1]):
        v = df.iloc[row, col]
        if pd.isna(v):
            break
        values.append(v)
    return values

def to_int_year(v):
    if pd.isna(v):
        return None
    s = str(v).strip()
    s = s.replace(".0", "")   # handle "2020.0"
    return int(float(s))      # handles floats like 2020.0

def extract_year_labels(df, row, start_col):
    """Extract year labels from row, starting at column start_col"""
    years = read_row_values_until_blank(df, row, start_col)
    years = [to_int_year(y) for y in years]
    return years

def extract_keyfigures_by_total_rows(df_key, value_col_index):
    """
    Extract values for each 'Key figures' year by:
      - finding rows in column A that start with "Key figures of"
      - for each such label, searching downward until the next label (or sheet end)
        and finding the first row where column B == "Total"
      - taking the value from value_col_index (0-based) at that 'Total' row

    Returns a DataFrame with columns: 'year' and the extracted values.
    """
    # Ensure columns exist
    nrows = df_key.shape[0]

    # Find all label rows where column A starts with "Key figures of"
    colA = df_key.iloc[:, 0].astype(str).fillna("")
    label_rows = []
    label_years = []
    for i, cell in enumerate(colA):
        if isinstance(cell, str) and cell.strip().lower().startswith("key figures of"):
            # extract the year (last word that contains digits) robustly
            m = re.search(r"(\d{4})\b", cell)
            if m:
                yr = int(m.group(1))
            else:
                # fallback: last token
                toks = cell.strip().split()
                yr = normalize_year_value(toks[-1]) if toks else None
            label_rows.append(i)
            label_years.append(yr)

    results = []
    # If there are no label rows, return empty df
    if not label_rows:
        return pd.DataFrame(columns=["year", value_col_index])

    # For block end detection, append nrows as sentinel
    label_rows_end = label_rows[1:] + [nrows]

    for start_row, end_row, year in zip(label_rows, label_rows_end, label_years):
        # search for first "Total" in column B (index 1) in rows start_row+1 .. end_row-1
        total_value = None
        for r in range(start_row + 1, end_row):
            cell_b = df_key.iloc[r, 1] if df_key.shape[1] > 1 else None
            if isinstance(cell_b, str):
                is_total = cell_b.strip().lower() == "total"
            else:
                is_total = (cell_b == "Total")
            if is_total:
                # get the value from requested column if present
                if value_col_index < df_key.shape[1]:
                    val = df_key.iloc[r, value_col_index]
                    # keep NaN as-is; if it is numeric string with comma, try to convert
                    if pd.isna(val):
                        total_value = None
                    else:
                        # try to convert strings like "1.234,56" or "1234,56" or "1234.56"
                        if isinstance(val, str):
                            s = val.strip()
                            # replace thousands separators if any and unify comma decimal
                            s = s.replace(" ", "").replace(".", "").replace(",", ".") if re.search(r"[,\.]\d{1,2}$", s) else s.replace(" ", "")
                            try:
                                total_value = float(s)
                            except Exception:
                                total_value = val  # leave as-is if conversion fails
                        else:
                            total_value = val
                break  # only the first Total in the block
        results.append({"year": year, "value": total_value})

    # Build dataframe and drop rows with year None (if any)
    df_out = pd.DataFrame(results)
    df_out = df_out[df_out["year"].notna()].copy()
    df_out["year"] = df_out["year"].astype(int)
    return df_out

def process_region_file(excel_path, output_csv):

    xls_file = pd.ExcelFile(excel_path)
    match_names = {name.lower(): name for name in xls_file.sheet_names}
    # -----------------------------------------
    # 1. READ SHEETS
    # -----------------------------------------
    df_exc_arrivals = pd.read_excel(excel_path, sheet_name=match_names["Arrivals-overnights-Occupancy".lower()], header=None)
    try:
        df_short = pd.read_excel(excel_path, sheet_name=match_names["Short stay_Arriv-Overnights".lower()], header=None)
    except KeyError:
        try:
            df_short = pd.read_excel(excel_path, sheet_name=match_names["Short stay_ArrivOvernights".lower()], header=None)
        except KeyError:
            df_short = pd.read_excel(excel_path, sheet_name=match_names["Short stay_ Arriv-Overnights".lower()], header=None)
    df_key = pd.read_excel(excel_path, sheet_name=match_names["Key Figures".lower()], header=None)
    df_emp = pd.read_excel(excel_path, sheet_name=match_names["Employment".lower()], header=None)

    # -----------------------------------------
    # 2. YEARS
    # -----------------------------------------
    years = extract_year_labels(df_exc_arrivals, row=3, start_col=2)

    # -------------------------------------------------------
    # 3–5. FIND BASE ROW ("Total") AND EXTRACT:
    #     - arrivals foreign/domestic
    #     - overnights foreign/domestic
    #     - occupancy
    # -------------------------------------------------------

    # Find the row in column A that contains "Total"
    total_row = None
    colA = df_exc_arrivals.iloc[:, 0].astype(str).str.strip().str.lower()

    for i, text in enumerate(colA):
        if text == "total":
            total_row = i
            break

    if total_row is None:
        raise ValueError("Could not find a 'Total' row in column A of sheet 'Arrivals-Overnights-Occupancy'")

    # Compute row indices
    arr_foreign_row   = total_row        # Foreign arrivals
    arr_domestic_row  = total_row + 1    # Domestic arrivals
    ov_foreign_row    = total_row + 2    # Foreign overnights
    ov_domestic_row   = total_row + 3    # Domestic overnights
    occupancy_row     = total_row + 4    # Occupancy

    # Extract values
    arr_foreign  = [int(x) for x in read_row_values_until_blank(df_exc_arrivals, arr_foreign_row, 2)]
    arr_domestic = [int(x) for x in read_row_values_until_blank(df_exc_arrivals, arr_domestic_row, 2)]

    ov_foreign   = [int(x) for x in read_row_values_until_blank(df_exc_arrivals, ov_foreign_row, 2)]
    ov_domestic  = [int(x) for x in read_row_values_until_blank(df_exc_arrivals, ov_domestic_row, 2)]

    # Occupancy: remove % and handle comma decimals
    occupancy_raw = read_row_values_until_blank(df_exc_arrivals, occupancy_row, 2)
    occupancy = [
        100 * float(str(x).replace("%", "").replace(",", ".")) if not pd.isna(x) else None
        for x in occupancy_raw
    ]

    # Build dataframes
    df_arrivals = pd.DataFrame({
        "year": years,
        "arrivals_foreign": arr_foreign,
        "arrivals_domestic": arr_domestic
    })
    df_arrivals["arrivals_total"] = df_arrivals["arrivals_foreign"] + df_arrivals["arrivals_domestic"]

    df_overnights = pd.DataFrame({
        "year": years,
        "overnights_foreign": ov_foreign,
        "overnights_domestic": ov_domestic
    })
    df_overnights["overnights_total"] = df_overnights["overnights_foreign"] + df_overnights["overnights_domestic"]

    df_occupancy = pd.DataFrame({
        "year": years,
        "occupancy": occupancy
    })


    # -------------------------------------------------------
    # 6. RECEIPTS ("Key figures", col D, start row 14 every +16 rows)
    # -------------------------------------------------------
    df_receipts_temp = extract_keyfigures_by_total_rows(df_key, value_col_index=3)
    df_receipts = df_receipts_temp.rename(columns={"value": "receipts"})
    # -------------------------------------------------------
    # 7. EXPENDITURE PER OVERNIGHT STAY (col G, same years as receipts)
    # -------------------------------------------------------
    df_exp_temp = extract_keyfigures_by_total_rows(df_key, value_col_index=6)
    df_exp = df_exp_temp.rename(columns={"value": "expenditure_per_overnight_stay"})

    # Merge with receipts (they share years)
    df_keyvars = pd.merge(df_receipts, df_exp, on="year", how="outer")

    # -------------------------------------------------------
    # 8. EMPLOYMENT
    # rows: 5,6,7,8; columns start at B until blank
    # -------------------------------------------------------
    years_emp = extract_year_labels(df_emp, row=3, start_col=1)

    emp_accom_cat = read_row_values_until_blank(df_emp, 4, 1)
    emp_other = read_row_values_until_blank(df_emp, 5, 1)
    emp_total = read_row_values_until_blank(df_emp, 6, 1)
    emp_greece = read_row_values_until_blank(df_emp, 7, 1)

    df_emp_all = pd.DataFrame({
        "year": years_emp,
        "employment_accomodation_catering": emp_accom_cat,
        "employment_other": emp_other,
        "employment_total": emp_total,
        "employment_total_greece": emp_greece
    })

    # -------------------------------------------------------
    # 9. MERGE EVERYTHING INTO ONE FINAL DF
    # -------------------------------------------------------
    df_final = (
        df_overnights
        .merge(df_arrivals, on="year", how="outer")
        .merge(df_occupancy, on="year", how="outer")
        .merge(df_keyvars, on="year", how="outer")
        .merge(df_emp_all, on="year", how="outer")
        .sort_values("year")
    )

    print(df_final)

    # -------------------------------------------------------
    # 10. SAVE CSV
    # -------------------------------------------------------
    df_final.to_csv(output_csv, index=False)

process_region_file("Attica_Region_ENG_26.xlsx", "INSETE_Attica.csv")
process_region_file("Central_Greece_Region_ENG_26.xlsx", "INSETE_Central_Greece.csv")
process_region_file("Central_Macedonia_Region_ENG_26.xlsx", "INSETE_Central_Macedonia.csv")
process_region_file("Crete_Region_ENG_26.xlsx", "INSETE_Crete.csv")
process_region_file("Eastern_Macedonia-Thrace_Region_ENG_26.xlsx", "INSETE_Eastern_Macedonia_Thrace.csv")
process_region_file("Epirus_Region_ENG_26.xlsx", "INSETE_Epirus.csv")
process_region_file("Ionian_Islands_Region_ENG_26.xlsx", "INSETE_Ionian_Islands.csv")
process_region_file("North_Aegean_Region_ENG_26-1.xlsx", "INSETE_North_Aegean.csv")
process_region_file("Peloponnese_Region_ENG_26.xlsx", "INSETE_Peloponnese.csv")
process_region_file("South_Aegean_Region_ENG_.xlsx", "INSETE_South_Aegean.csv")
process_region_file("Thessaly_Region_ENG_26.xlsx", "INSETE_Thessaly.csv")
process_region_file("Western_Greece_Region_ENG_26.xlsx", "INSETE_Western_Greece.csv")
process_region_file("Western_Macedonia_Region_ENG_26.xlsx", "INSETE_Western_Macedonia.csv")
