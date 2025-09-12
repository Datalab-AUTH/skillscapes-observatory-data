#!/usr/bin/env python3

import pandas as pd

def process_region_file(excel_path, output_csv):
    # Read only 3rd sheet (index 2)
    df = pd.read_excel(excel_path, sheet_name=2, header=None)

    # Get region name from cell A5 (row index 4, col 0)
    region_name = df.iloc[4, 0]

    # Filter only rows where col B == "Total"
    total_rows = df[df[1] == "Total"].copy()

    # Extract only columns F–H (indices 5–7)
    total_rows = total_rows[[5, 6, 7]].copy()
    total_rows.columns = ["Avg_expenditure_per_journey", "Avg_expenditure_per_stay", "Avg_duration_of_stay"]

    # Assign Year from 2024 down to 2016
    years = list(range(2024, 2015, -1))  # 2024 → 2016
    if len(total_rows) != len(years):
        raise ValueError(
            f"Expected {len(years)} 'Total' rows, found {len(total_rows)}."
        )
    total_rows["Year"] = years

    # Add Region column
    total_rows["Region"] = region_name

    # Save CSV
    total_rows.to_csv(output_csv, index=False)

process_region_file("data_original/SS33-Attica.xlsx", "data_csv/SS33-Attica.csv")
process_region_file("data_original/SS33-Central_Greece.xlsx", "data_csv/SS33-Central_Greece.csv")
process_region_file("data_original/SS33-Central_Macedonia.xlsx", "data_csv/SS33-Central_Macedonia.csv")
process_region_file("data_original/SS33-Crete.xlsx", "data_csv/SS33-Crete.csv")
process_region_file("data_original/SS33-Eastern_Macedonia-Thrace.xlsx", "data_csv/SS33-Eastern_Macedonia-Thrace.csv")
process_region_file("data_original/SS33-Epirus.xlsx", "data_csv/SS33-Epirus.csv")
process_region_file("data_original/SS33-Ionian_Islands.xlsx", "data_csv/SS33-Ionian_Islands.csv")
process_region_file("data_original/SS33-North_Aegean.xlsx", "data_csv/SS33-North_Aegean.csv")
process_region_file("data_original/SS33-Peloponnese.xlsx", "data_csv/SS33-Peloponnese.csv")
process_region_file("data_original/SS33-South_Aegean.xlsx", "data_csv/SS33-South_Aegean.csv")
process_region_file("data_original/SS33-Thessaly.xlsx", "data_csv/SS33-Thessaly.csv")
process_region_file("data_original/SS33-Western_Greece.xlsx", "data_csv/SS33-Western_Greece.csv")
process_region_file("data_original/SS33-Western_Macedonia.xlsx", "data_csv/SS33-Western_Macedonia.csv")

