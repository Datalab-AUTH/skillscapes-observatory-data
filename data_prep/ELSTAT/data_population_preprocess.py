#!/usr/bin/env python3

import pandas as pd

def read_excel(file_path):
    sheet_name = "Sheet1"

    # Load without headers to detect where "En_label" appears
    df = pd.read_excel(file_path, sheet_name=sheet_name, header=None)

    # Header row starting at column B
    header_row = df.iloc[0, 1:]

    # Locate "En_label"
    en_label_index = header_row[header_row == "En_label"].index[0]

    # Select from column B to "En_label"
    cols = list(range(1, en_label_index + 1))

    # Load again with real headers
    data = pd.read_excel(
        file_path,
        sheet_name=sheet_name,
        usecols=cols,
        header=0
    )

    # Rename En_label → region
    data = data.rename(columns={"En_label": "region"})

    # Identify year columns (all except region)
    year_cols = [col for col in data.columns if col != "region"]

    # Melt to long format
    long_df = data.melt(
        id_vars="region",
        value_vars=year_cols,
        var_name="year",
        value_name="population"
    )

    # Convert year column to numeric if possible
    long_df["year"] = pd.to_numeric(long_df["year"], errors="ignore")

    return long_df

df = read_excel("Regional units_pop.xlsx")
df.to_csv("population_by_region.csv", index=False)
