#!/usr/bin/env python3

import pandas as pd

def excel_to_long_csv(excel_path, csv_path):
    # Read Excel without header
    df = pd.read_excel(excel_path, header=None)

    # --- CONFIG (0-based indexing) ---
    label_col = 277              # JR
    year_cols = list(range(93, 116))    # CP:DL (2000–2022)
    total_cols = list(range(254, 277))  # IU:JQ (2000–2022 totals)
    header_row = 11              # Excel row 12
    data_start = 12              # Excel row 13
    data_end = 86                # Excel row 87

    # Year labels
    years = list(range(2000,2023))

    # Extract data rows
    data = df.loc[data_start:data_end, :]

    # Labels
    labels = data[label_col].values

    # --- GVA values ---
    values = data[year_cols].copy()
    values.columns = years
    values["NUTS"] = labels
    values_long = values.melt(id_vars="NUTS", var_name="Year", value_name="GVA")

    # --- Totals ---
    totals = data[total_cols].copy()
    totals.columns = years
    totals["NUTS"] = labels
    totals_long = totals.melt(id_vars="NUTS", var_name="Year", value_name="Total")

    # --- Merge GVA + Total ---
    long_df = pd.merge(values_long, totals_long, on=["NUTS", "Year"], how="left")

    # --- Enforce Year as integer ---
    long_df["Year"] = (
        long_df["Year"]
        .astype(str)
        .str.replace("*", "", regex=False)   # remove literal "*"
        .replace("", pd.NA)
    )
    long_df["Year"] = pd.to_numeric(long_df["Year"], errors="coerce").astype("Int64")

    # Save
    long_df.to_csv(csv_path, index=False)

# Example usage:
excel_to_long_csv("data_original/SS25.xlsx", "data_csv/SS25.csv")

