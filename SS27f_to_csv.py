#!/usr/bin/env python3

# This is for SS27-2015.xls only

import pandas as pd

def process_xls_single_sheet(excel_path, output_csv):
    start_row = 10   # Row 10 in Excel
    end_row = 96    # Row 97 in Excel

    df = pd.read_excel(excel_path, sheet_name=0, header=None)

    # Slice data rows
    data = df.iloc[start_row:end_row + 1].copy()

    # Forward-fill NUTS2 (col 0)
    data[0] = data[0].ffill()

    # Hotels data: G–I (cols 6, 7, 8)
    hotels = data[[0, 1, 6, 7, 8, 9]].copy()
    hotels.columns = [
        "NUTS2", "NUTS3",
        "Hotel_Arrivals_Natives",
        "Hotel_Arrivals_Foreign",
        "Hotel_Arrivals_Total",
        "Hotel_Beds"
    ]

    # Campings data: N–P (cols 13, 14, 15)
#    campings = data[[0, 1, 13, 14, 15]].copy()
#    campings.columns = [
#        "NUTS2", "NUTS3",
#        "Campings_Arrivals_Natives",
#        "Campings_Arrivals_Foreign",
#        "Campings_Arrivals_Total"
#    ]

    # Replace "(1)" with NaN
    hotels = hotels.replace("(1)", pd.NA)
#    campings = campings.replace("(1)", pd.NA)

    # Merge on NUTS2 + NUTS3 (left join)
    #merged = hotels.merge(campings, on=["NUTS2", "NUTS3"], how="left")

    # Save CSV
    hotels.to_csv(output_csv, index=False)
    #merged.to_csv(output_csv, index=False)

process_xls_single_sheet("data_original/SS27-2015.xls", "data_csv/SS27-2015.csv")

