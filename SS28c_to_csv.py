#!/usr/bin/env python3

# This is for SS27-2019.xlsx to SS27-2018.xlsx

import pandas as pd

def process_single_sheet(excel_path, output_csv):
    start_row = 9   # Row 10 in Excel
    end_row = 95    # Row 96 in Excel

    df = pd.read_excel(excel_path, sheet_name=0, header=None)

    # Slice data rows
    data = df.iloc[start_row:end_row + 1].copy()

    # Forward-fill and clean labels
    data[0] = data[0].ffill()

    # Hotels data: H–L (cols 7-11)
    hotels = data[[0, 1, 7, 8, 9, 10, 11]].copy()
    hotels.columns = [
        "NUTS2", "NUTS3",
        "Hotel_Stays_Natives",
        "Hotel_Stays_Foreign",
        "Hotel_Stays_Total",
        "Hotel_Beds",
        "Hotel_Occupancy"
    ]
    hotels.to_csv(output_csv, index=False)

process_single_sheet("data_original/SS28-2019.xls", "data_csv/SS28-2019.csv")
process_single_sheet("data_original/SS28-2018.xls", "data_csv/SS28-2018.csv")

