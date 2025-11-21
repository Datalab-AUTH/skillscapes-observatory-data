#!/usr/bin/env python3

import pandas as pd

def find_starting_point(df, max_rows=10, max_cols=1000, target="Regional Unit"):
    """
    Scan the first `max_rows` rows and `max_cols` columns
    to find the third cell whose value equals (case-insensitive)
    `target`. Returns (row_index, col_index).
    """
    count = 0

    # Limit scanning to available dimensions
    max_r = min(max_rows, df.shape[0])
    max_c = min(max_cols, df.shape[1])

    target_lower = target.lower()

    for r in range(max_r):
        for c in range(max_c):
            val = df.iat[r, c]
            if isinstance(val, str) and val.strip().lower() == target_lower:
                count += 1
                if count == 3:
                    return r, c

    raise ValueError("Could not find the 3rd occurrence of 'Regional Unit' within the scan range.")


def extract_STR_data(excel_file, sheet_name):
    # Read the worksheet without header so we can manually pick rows
    df = pd.read_excel(excel_file, sheet_name=sheet_name, header=None)

    # Config
    start_row, start_col = find_starting_point(df)

    ROW_YEAR_LABELS = start_row       # row containing year labels + "Regional Unit"
    COL_REGION      = start_col       # region column
    COL_MONTH       = start_col + 1   # month column
    COL_FIRST_YEAR  = start_col + 2   # first year column

    # The actual table data starts on the NEXT row
    ROW_START = ROW_YEAR_LABELS + 1

    # determine starting column
    regional_unit_positions = []

    for col in range(df.shape[1]):
        cell = df.iat[ROW_YEAR_LABELS, col]
        if isinstance(cell, str) and cell.strip().lower() == "regional unit":
            regional_unit_positions.append(col)

    if len(regional_unit_positions) < 3:
        raise ValueError("Could not find the 3rd 'Regional Unit' label in row 3.")

    # Extract the year labels from row 3 starting at column Y
    years = []
    col = COL_FIRST_YEAR
    while True:
        try:
            val = df.iat[ROW_YEAR_LABELS, col]
        except IndexError:
            break
        years.append(val)
        col += 1

    # Build list of all value columns
    value_cols = list(range(COL_FIRST_YEAR, COL_FIRST_YEAR + len(years)))

    records = []

    current_region = None

    for r in range(ROW_START, len(df)):
        region = df.iat[r, COL_REGION]
        month  = df.iat[r, COL_MONTH]

        # If the cell contains the "Source:" marker → stop reading
        if isinstance(region, str) and region.startswith("Source:"):
            break

        # Forward fill region logic
        if isinstance(region, str) and region.strip() != "":
            current_region = region
        # otherwise keep previous current_region

        # If month is empty, skip row completely
        if pd.isna(month) or str(month).strip() == "":
            continue
        else:
            month = int(month)

        # Extract yearly values in this row
        for i, col in enumerate(value_cols):
            year = int(years[i])
            value = int(df.iat[r, col])

            # If no data at all → stop parsing values for this row
            if pd.isna(value):
                continue

            records.append({
                "region": current_region,
                "month": month,
                "year": year,
                "STR_accomodation_beds_by_month": value
            })

    # Convert to DataFrame
    result = pd.DataFrame(records)
    return(result)

# ----------------------------------------
# Get data from all regions and merge them
# ----------------------------------------
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

# in most sheets the sheet is "STR Capacity", but not for South
# Aegean...
sheet_name = "STR capacity"

df_attica = extract_STR_data("Attica_Region_ENG_26.xlsx", sheet_name)
df_central_greece = extract_STR_data("Central_Greece_Region_ENG_26.xlsx", sheet_name)
df_central_macedonia = extract_STR_data("Central_Macedonia_Region_ENG_26.xlsx", sheet_name)
df_crete = extract_STR_data("Crete_Region_ENG_26.xlsx", sheet_name)
df_eastern_macedonia = extract_STR_data("Eastern_Macedonia-Thrace_Region_ENG_26.xlsx", sheet_name)
df_epirus = extract_STR_data("Epirus_Region_ENG_26.xlsx", sheet_name)
df_ionian_islands = extract_STR_data("Ionian_Islands_Region_ENG_26.xlsx", sheet_name)
df_north_aegean = extract_STR_data("North_Aegean_Region_ENG_26-1.xlsx", sheet_name)
df_peloponnese = extract_STR_data("Peloponnese_Region_ENG_26.xlsx", sheet_name)
df_thessaly = extract_STR_data("Thessaly_Region_ENG_26.xlsx", sheet_name)
df_western_greece = extract_STR_data("Western_Greece_Region_ENG_26.xlsx", sheet_name)
df_western_macedonia = extract_STR_data("Western_Macedonia_Region_ENG_26.xlsx", sheet_name)
# see... South Aegean has different sheets for Cyclades and
# Dodecanese...
df_south_aegean_cyclades = extract_STR_data("South_Aegean_Region_ENG_.xlsx",
                                     "STR capacity Cyclades")
df_south_aegean_dodecanese = extract_STR_data("South_Aegean_Region_ENG_.xlsx",
                                     "STR capacity Dodecanese")

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
  df_south_aegean_cyclades,
  df_south_aegean_dodecanese,
  df_thessaly,
  df_western_greece,
  df_western_macedonia,
])

print(df_all)
df_all.to_csv("INSETE_STR.csv", index=False)
