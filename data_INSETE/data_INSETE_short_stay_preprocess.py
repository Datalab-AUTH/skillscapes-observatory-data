#!/usr/bin/env python3

import pandas as pd
import re

def extract_region_name(s):
    parts = s.split(":")[0].strip()
    if "REGION" in parts:
        parts = parts.replace("REGION", "").strip()
    return parts

def extract_overnight_data(path_to_xlsx):
    xls_file = pd.ExcelFile(path_to_xlsx)
    match_names = {name.lower(): name for name in xls_file.sheet_names}
    # Load the workbook
    try:
        df = pd.read_excel(path_to_xlsx, sheet_name=match_names["Short stay_Arriv-Overnights".lower()], header=None)
    except KeyError:
        try:
            df = pd.read_excel(path_to_xlsx, sheet_name=match_names["Short stay_ArrivOvernights".lower()], header=None)
        except KeyError:
            df = pd.read_excel(path_to_xlsx, sheet_name=match_names["Short stay_ Arriv-Overnights".lower()], header=None)

    # ------------------------------------------------------------------
    # 1. Locate the header row (the row where column A == "Regional Unit")
    # ------------------------------------------------------------------
    header_row_idx = df.index[df[0].astype(str).str.startswith("Regional Unit", na=False)]
    if len(header_row_idx) == 0:
        raise ValueError("Could not find a row where column A contains 'Regional Unit'")
    header_row = header_row_idx[0]

    # ------------------------------------------------------------------
    # 2. Extract year labels from the header row (columns C onward)
    # ------------------------------------------------------------------
    years = []
    for col in range(2, df.shape[1]):
        val = df.at[header_row, col]
        if pd.isna(val):
            break
        years.append(int(val))

    # ------------------------------------------------------------------
    # 3. Extract the REGION_NAME (cell A3)
    # ------------------------------------------------------------------
    cell_A3 = str(df.at[2, 0])  # A3 is row index 2, col index 0
    region_name_for_total = extract_region_name(cell_A3) 

    # ------------------------------------------------------------------
    # 4. Walk through rows below the header and collect region + variables
    # ------------------------------------------------------------------
    data_rows = []
    current_region = None

    row = header_row + 1
    while row < len(df):
        region_candidate = df.at[row, 0]
        variable_name = df.at[row, 1]

        # If both Region and Variable are NaN, we reached the end
        if pd.isna(region_candidate) and pd.isna(variable_name):
            break

        # Update region label when new text appears
        if isinstance(region_candidate, str) and region_candidate.strip() != "":
            current_region = region_candidate.strip()

        # Skip rows until we have a region and a variable name
        if current_region is None or pd.isna(variable_name):
            row += 1
            continue

        # Replace "Total" region with extracted REGION_NAME
        if current_region == "Total":
            current_region = region_name_for_total
        current_region = current_region.strip('*')

        variable_name = str(variable_name).strip()

        # Only capture known variable categories
        if (variable_name in [
                "Foreign arrivals",
                "Domestic arrivals",
                "Foreign overnights",
                "Domestic overnights" 
            ]):
            variable_name_final = "_".join(["short_stay",
                                                variable_name])

            # For every year column, record value
            for i, year in enumerate(years):
                col = 2 + i
                try:
                    val = int(df.at[row, col])
                except ValueError:
                    val = None
                data_rows.append({
                    "region": current_region,
                    "variable": variable_name_final,
                    "year": year,
                    "value": val
                })

        row += 1

    # Convert to DataFrame
    result = pd.DataFrame(data_rows)
    return result


# -----------------------------
# Example usage:
# -----------------------------
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)
df_attica = extract_overnight_data("Attica_Region_ENG_26.xlsx")
df_central_greece = extract_overnight_data("Central_Greece_Region_ENG_26.xlsx")
df_central_macedonia = extract_overnight_data("Central_Macedonia_Region_ENG_26.xlsx")
df_crete = extract_overnight_data("Crete_Region_ENG_26.xlsx")
df_eastern_macedonia = extract_overnight_data("Eastern_Macedonia-Thrace_Region_ENG_26.xlsx")
df_epirus = extract_overnight_data("Epirus_Region_ENG_26.xlsx")
df_ionian_islands = extract_overnight_data("Ionian_Islands_Region_ENG_26.xlsx")
df_north_aegean = extract_overnight_data("North_Aegean_Region_ENG_26-1.xlsx")
df_peloponnese = extract_overnight_data("Peloponnese_Region_ENG_26.xlsx")
df_south_aegean = extract_overnight_data("South_Aegean_Region_ENG_.xlsx")
df_thessaly = extract_overnight_data("Thessaly_Region_ENG_26.xlsx")
df_western_greece = extract_overnight_data("Western_Greece_Region_ENG_26.xlsx")
df_western_macedonia = extract_overnight_data("Western_Macedonia_Region_ENG_26.xlsx")

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
df_all.to_csv("INSETE_short_stay.csv", index=False)
