#!/usr/bin/env python3

# This is for SS27-2020.xlsx only

import pandas as pd

def clean_labels(series):
    """Strip spaces and remove ' (2)' at the end of labels."""
    return (
        series.astype(str)
        .str.strip()
        .str.replace(" (2)", "", regex=False)
        .replace("nan", pd.NA)
    )

def read_sheet(excel_path, sheet_index, col_indices, col_names, start_row, end_row):
    """Reads one sheet, processes labels, takes fixed row range, and returns DataFrame."""
    df = pd.read_excel(excel_path, sheet_name=sheet_index, header=None)

    # Fixed row range
    data = df.iloc[start_row:end_row + 1].copy()

    # Forward-fill NUTS2
    data[0] = data[0].ffill()

    # Clean label columns
    data[0] = clean_labels(data[0])
    data[1] = clean_labels(data[1])

    # Extract labels + specified value columns
    data = data[[0, 1] + col_indices].copy()
    data.columns = ["NUTS2", "NUTS3"] + col_names

    # Replace "(1)" with NaN
    data = data.replace("(1)", pd.NA)

    return data

def process_file_two_sheets(excel_path, output_csv):
    start_row = 9   # Row 10 in Excel
    end_row = 95    # Row 96 in Excel

    # Hotels
    hotels = read_sheet(
        excel_path,
        sheet_index=0,
        col_indices=list(range(2, 6)),  # C–F
        col_names=[
            "Hotel_Arrivals_Natives",
            "Hotel_Arrivals_Foreign",
            "Hotel_Arrivals_Total",
            "Hotel_Beds"
        ],
        start_row=start_row,
        end_row=end_row
    )

    # Campings
#    campings = read_sheet(
#        excel_path,
#        sheet_index=1,
#        col_indices=list(range(2, 5)),  # C–E
#        col_names=[
#            "Campings_Arrivals_Natives",
#            "Campings_Arrivals_Foreign",
#            "Campings_Arrivals_Total"
#        ],
#        start_row=start_row,
#        end_row=end_row
#    )
#
#    # Merge all by NUTS2 + NUTS3
#    merged = hotels.merge(campings, on=["NUTS2", "NUTS3"], how="left")
#
#    # Save CSV
#    merged.to_csv(output_csv, index=False)
    hotels.to_csv(output_csv, index=False)


# Example usage:
process_file_two_sheets("data_original/SS27-2020.xlsx", "data_csv/SS27-2020.csv")

