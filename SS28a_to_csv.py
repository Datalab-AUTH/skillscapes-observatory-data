#!/usr/bin/env python3
#
# This is for files SS28-2024.xlsx only
import pandas as pd

def read_sheet(excel_path, sheet_index, col_indices, col_names):
    """Reads one sheet, processes labels, takes fixed row range, and returns DataFrame."""
    df = pd.read_excel(excel_path, sheet_name=sheet_index, header=None)

    # Data from row 6 to row 93 inclusive (Excel) → index 5 to 92
    data = df.iloc[5:92].copy()

    # Forward-fill NUTS2
    data[0] = data[0].ffill()

    # Extract labels + specified value columns
    data = data[[0, 1] + col_indices].copy()
    data.columns = ["NUTS2", "NUTS3"] + col_names

    return data

def process_file(excel_path, output_csv):
    # Hotels
    hotels = read_sheet(
        excel_path,
        sheet_index=0,
        col_indices=list(range(2, 7)),  # C–F
        col_names=[
            "Hotel_Stays_Natives",
            "Hotel_Stays_Foreign",
            "Hotel_Stays_Total",
            "Hotel_Beds",
            "Hotel_Occupancy"
        ]
    )
    hotels.to_csv(output_csv, index=False)

# Example usage:
process_file("data_original/SS28-2024.xlsx", "data_csv/SS28-2024.csv")

