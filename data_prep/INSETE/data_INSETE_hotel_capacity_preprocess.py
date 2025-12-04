#!/usr/bin/env python3

import pandas as pd
import sys
import re

def clean_region_name(s):
    """Remove the word 'REGION' and trim whitespace."""
    s = str(s)
    s = s.replace("REGION", "").strip()
    return s

def parse_year_from_title(s):
    """Extract year from string like 'Hotel Capacity 2024'."""
    m = re.search(r"(\d{4})", str(s))
    if not m:
        return None
    return int(m.group(1))

def extract_hotel_capacity(path_to_xlsx):
    xls_file = pd.ExcelFile(path_to_xlsx)
    match_names = {name.lower().strip(): name for name in xls_file.sheet_names}
    # Load the workbook
    df = pd.read_excel(path_to_xlsx, sheet_name=match_names["Hotel Capacity".lower()], header=None)

    results = []
    row = 0
    max_row = len(df)

    while True:
        # Find next "Regional Unit"
        ru_rows = df.index[df[0].astype(str).str.startswith("Regional Unit")]
        ru_rows = [r for r in ru_rows if r >= row]

        if not ru_rows:
            break  # no more tables

        header_row = ru_rows[0]

        # Extract meta-information
        region_header_cell = df.at[header_row - 2, 0]
        general_region = clean_region_name(region_header_cell)

        title_cell = df.at[header_row - 1, 0]
        year = parse_year_from_title(title_cell)
        if year is None:
            raise ValueError(f"Could not parse year from: {title_cell}")

        # Walk the table
        current_region = None
        r = header_row + 1

        while r < max_row:
            colA = df.at[r, 0]

            # Stop condition
            if isinstance(colA, str) and colA.startswith("Source:"):
                break

            # Column A = region (may be empty)
            if isinstance(colA, str) and colA.strip():
                current_region = colA.strip()

            # If empty, reuse previous region
            if current_region is None:
                r += 1
                continue

            # Replace "Total"
            if current_region == "Total":
                current_region = general_region

            # Column B = variable
            variable_name = df.at[r, 1]
            if pd.isna(variable_name):
                r += 1
                continue
            variable_name = str(variable_name).strip()

            # Column H = value (col index 7)
            val = df.at[r, 7]
            try:
                val = int(val)
            except:
                val = None

            results.append({
                "region": current_region,
                "variable": variable_name.lower().replace(' ', '_'),
                "year": year,
                "value": val
            })

            r += 1

        row = r + 1  # continue searching after this table

    if len(results) == 0:
        print("No results for f{path_to_xlsx}")
        sys.exit(1)
    return pd.DataFrame(results)

# ----------------------------------------
# Get data from all regions and merge them
# ----------------------------------------
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)
df_attica = extract_hotel_capacity("Attica_Region_ENG_26.xlsx")
df_central_greece = extract_hotel_capacity("Central_Greece_Region_ENG_26.xlsx")
df_central_macedonia = extract_hotel_capacity("Central_Macedonia_Region_ENG_26.xlsx")
df_crete = extract_hotel_capacity("Crete_Region_ENG_26.xlsx")
df_eastern_macedonia = extract_hotel_capacity("Eastern_Macedonia-Thrace_Region_ENG_26.xlsx")
df_epirus = extract_hotel_capacity("Epirus_Region_ENG_26.xlsx")
df_ionian_islands = extract_hotel_capacity("Ionian_Islands_Region_ENG_26.xlsx")
df_north_aegean = extract_hotel_capacity("North_Aegean_Region_ENG_26-1.xlsx")
df_peloponnese = extract_hotel_capacity("Peloponnese_Region_ENG_26.xlsx")
df_south_aegean = extract_hotel_capacity("South_Aegean_Region_ENG_.xlsx")
df_thessaly = extract_hotel_capacity("Thessaly_Region_ENG_26.xlsx")
df_western_greece = extract_hotel_capacity("Western_Greece_Region_ENG_26.xlsx")
df_western_macedonia = extract_hotel_capacity("Western_Macedonia_Region_ENG_26.xlsx")

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
df_all.to_csv("INSETE_hotel_capacity.csv", index=False)
