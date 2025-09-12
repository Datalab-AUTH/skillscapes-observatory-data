#!/usr/bin/env python3
#
# This is for files SS27-2023.xlsx to SS27-2021.xlsx
import pandas as pd

def clean_labels(series):
    """Strip spaces and remove ' (2)' at the end of labels."""
    return (
        series.astype(str)
        .str.strip()
        .str.replace(" (2)", "", regex=False)
        .replace("nan", pd.NA)
    )

def read_sheet(excel_path, sheet_index, col_indices, col_names):
    """Reads one sheet, processes labels, takes fixed row range, and returns DataFrame."""
    df = pd.read_excel(excel_path, sheet_name=sheet_index, header=None)

    # Data from row 9 to row 95 inclusive (Excel) → index 8 to 94
    data = df.iloc[8:95].copy()

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

def process_file(excel_path, output_csv):
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
        ]
    )

    # Rentals
#    rentals = read_sheet(
#        excel_path,
#        sheet_index=1,
#        col_indices=list(range(2, 5)),  # C–E
#        col_names=[
#            "Rentals_Arrivals_Natives",
#            "Rentals_Arrivals_Foreign",
#            "Rentals_Arrivals_Total"
#        ]
#    )
#
#    # Campings
#    campings = read_sheet(
#        excel_path,
#        sheet_index=2,
#        col_indices=list(range(2, 5)),  # C–E
#        col_names=[
#            "Campings_Arrivals_Natives",
#            "Campings_Arrivals_Foreign",
#            "Campings_Arrivals_Total"
#        ]
#    )
#
#    # Merge all by NUTS2 + NUTS3
#    merged = hotels.merge(rentals, on=["NUTS2", "NUTS3"], how="outer")
#    merged = merged.merge(campings, on=["NUTS2", "NUTS3"], how="outer")
#
#    # Save CSV
#    merged.to_csv(output_csv, index=False)
    hotels.to_csv(output_csv, index=False)

# Example usage:
process_file("data_original/SS27-2023.xlsx", "data_csv/SS27-2023.csv")
process_file("data_original/SS27-2022.xlsx", "data_csv/SS27-2022.csv")

