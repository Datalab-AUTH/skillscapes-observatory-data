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

def extract_employment_data(excel_path):
    xls_file = pd.ExcelFile(excel_path)
    match_names = {name.lower(): name for name in xls_file.sheet_names}
    # read sheet
    df_emp = pd.read_excel(excel_path, sheet_name=match_names["Employment".lower()], header=None)
    # get region name (easier to get it from the key figures sheet)
    df_key = pd.read_excel(excel_path, sheet_name=match_names["Key Figures".lower()], header=None)
    region = df_key.at[4,0]
    
    years_emp = extract_year_labels(df_emp, row=3, start_col=1)

    emp_accom_cat = read_row_values_until_blank(df_emp, 4, 1)
    emp_other = read_row_values_until_blank(df_emp, 5, 1)
    emp_total = read_row_values_until_blank(df_emp, 6, 1)
    emp_greece = read_row_values_until_blank(df_emp, 7, 1)

    df_emp_all = pd.DataFrame({
        "region": region,
        "year": years_emp,
        "employment_accommodation_catering": emp_accom_cat,
        "employment_other": emp_other,
        "employment_total": emp_total,
        "employment_total_greece": emp_greece
    })
    return(df_emp_all)

# ----------------------------------------
# Get data from all regions and merge them
# ----------------------------------------
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)
df_attica = extract_employment_data("Attica_Region_ENG_26.xlsx")
df_central_greece = extract_employment_data("Central_Greece_Region_ENG_26.xlsx")
df_central_macedonia = extract_employment_data("Central_Macedonia_Region_ENG_26.xlsx")
df_crete = extract_employment_data("Crete_Region_ENG_26.xlsx")
df_eastern_macedonia = extract_employment_data("Eastern_Macedonia-Thrace_Region_ENG_26.xlsx")
df_epirus = extract_employment_data("Epirus_Region_ENG_26.xlsx")
df_ionian_islands = extract_employment_data("Ionian_Islands_Region_ENG_26.xlsx")
df_north_aegean = extract_employment_data("North_Aegean_Region_ENG_26-1.xlsx")
df_peloponnese = extract_employment_data("Peloponnese_Region_ENG_26.xlsx")
df_south_aegean = extract_employment_data("South_Aegean_Region_ENG_.xlsx")
df_thessaly = extract_employment_data("Thessaly_Region_ENG_26.xlsx")
df_western_greece = extract_employment_data("Western_Greece_Region_ENG_26.xlsx")
df_western_macedonia = extract_employment_data("Western_Macedonia_Region_ENG_26.xlsx")

df_all = pd.concat([
  df_attica,
  df_central_greece,
  df_central_macedonia,
  df_crete,
  df_eastern_macedonia,
  df_epirus,
  df_ionian_islands,
  df_north_aegean,
  df_peloponnese,
  df_south_aegean,
  df_thessaly,
  df_western_greece,
  df_western_macedonia,
])

print(df_all)
df_all.to_csv("INSETE_employment.csv", index=False)
