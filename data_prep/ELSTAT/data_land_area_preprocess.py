#!/usr/bin/env python3

import pandas as pd

def read_xlsx(xlsx_path):
    df = pd.read_excel(xlsx_path, sheet_name="Περιφερειακές Ενότητες", skiprows=3)
    df = df.iloc[:, [2, 4]]
    df.columns = ['region', 'land_area']
    return df

df = read_xlsx("A1602_SAM08_TB_DC_00_2021_01_F_GR.xls")
df.to_csv("gr_land_area.csv", index=False)
