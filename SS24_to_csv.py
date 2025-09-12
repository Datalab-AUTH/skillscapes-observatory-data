#!/usr/bin/env python3

import pandas as pd

def excel_to_long_csv(excel_path, csv_path):
    # Read the Excel file fully (pandas handles .xlsx via openpyxl)
    df = pd.read_excel(excel_path, header=None)

    records = []

    # Start at year 2000, ends at 2022
    start_year = 2000
    end_year = 2022

    # Data starts at line 13 (Excel is 1-based, pandas is 0-based → index 12)
    row = 12
    current_year = start_year

    while current_year <= end_year and row < len(df):
        # Row at 'row' is header for current_year
        header_row = row

        # Data rows follow, until next header line
        # Each block has 18 rows of data (14–31, 33–50, etc.)
        start_data = header_row + 1
        end_data = header_row + 18  # inclusive

        for r in range(start_data, min(end_data + 1, len(df))):
            value = df.iloc[r, 4]   # column E (0-based index = 4)
            label_latin = df.iloc[r, 13]  # column N (0-based index = 13)
            label_el = df.iloc[r, 0]  # column N (0-based index = 13)
            total = df.iloc[r, 11] # total GFCF

            # Skip completely empty rows
            if pd.isna(value) and pd.isna(label):
                continue

            records.append({
                "Year": current_year,
                "NUTS": label_latin,
                "NUTS_el": label_el,
                "GFCF_GHI": value,
                "GFCF_Total": total
            })

        # Move to next header
        row = end_data + 1
        current_year += 1

    # Convert to DataFrame and save as CSV
    long_df = pd.DataFrame(records)
    long_df.to_csv(csv_path, index=False)

excel_to_long_csv("data_original/SS24.xlsx", "data_csv/SS24.csv")
