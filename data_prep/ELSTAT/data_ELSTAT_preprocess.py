#!/usr/bin/env python3

import pandas as pd

def read_excel_long(excel_path):
    """Read one Excel file and return a long-format DataFrame with NUTS2, NUTS3, Year, Value."""
    df = pd.read_excel(excel_path, sheet_name=0, header=None)

    # --- CONFIG ---
    label_a_col = 0
    label_b_col = 1
    year_cols = list(range(2, 9))  # C:H (2019–2025)
    header_row = 3                 # Excel row 4
    data_start = 4                 # Excel row 5
    data_end = 70                  # Excel row 71

    # Get year labels from header row
    years = df.loc[header_row, year_cols].values

    # Get data block
    data = df.loc[data_start:data_end, :].copy()

    # Forward-fill NUTS2 where missing
    data[label_a_col] = data[label_a_col].ffill()

    # Extract labels
    label_a = data[label_a_col].values
    label_b = data[label_b_col].values

    # Extract year values
    values = data[year_cols].copy()
    values.columns = years

    # Replace double asterisks (**) with NaN
    values = values.replace("**", pd.NA)

    # Melt into long format
    long_df = values.assign(NUTS2=label_a, NUTS3=label_b).melt(
        id_vars=["NUTS2", "NUTS3"],
        var_name="Year",
        value_name="Value"
    )

    # Ensure Year is integer
    long_df["Year"] = pd.to_numeric(long_df["Year"], errors="coerce").astype("Int64")

    return long_df


# Read both files
df1 = read_excel_long("SBR03_01.xlsx").rename(columns={"Value": "Turnover_Accomodation"})
df2 = read_excel_long("SBR03_02.xlsx").rename(columns={"Value": "Turnover_Catering"})

# Merge on labels and year
merged = pd.merge(df1, df2, on=["NUTS2", "NUTS3", "Year"], how="outer")

# Save the csv
merged.to_csv("ELSTAT_SBR03.csv", index=False)
