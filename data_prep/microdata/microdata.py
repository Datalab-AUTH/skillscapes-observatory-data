#!/usr/bin/env python3

import pandas as pd

# # Get data - Instructions
# 
# - Visit microdata app --> "Overview" tab: https://geo-api.aegean.gr/microdata-app/
# 
# #### Involuntary Part-Time Employment
# - Group by `REGION_2D` and `FTPT` and `FTPTREAS`
# - Target variable `AGE_GRP`
# - Download data from section _Get data for multiple countries and years_ (file around 20MB)
# 
# 
# #### Involuntary Temporary Employment
# - Group by `REGION_2D` and `TEMP` and `TEMPREAS`
# - Target variable `AGE_GRP`
# - Download data from section _Get data for multiple countries and years_ (file around 20MB)
# 

# ## Involuntary Part-Time Employment
## Input data
FILENAME = "microdata__Multi_Years_Country_Group_REGION_2D-FTPT-FTPTREAS__Target_AGE_GRP.csv"

## Output data
SAVE_FILENAME = "NUTS2_Involuntary_Part_Time_Employment.csv"
df_ftpt = pd.read_csv(FILENAME)
df_ftpt
df_ftpt["FTPT"].value_counts()
df_ftpt["FTPTREAS"].value_counts()
df_ftpt["AGE_GRP"].value_counts()
df_involuntary_part_time = df_ftpt[\
      (df_ftpt["FTPT"]=="Part-time job")&\
      (df_ftpt["FTPTREAS"]=="Could not find a full-time job")&\
      (df_ftpt["AGE_GRP"].isin(["15-19 years of age",
                                "20-24 years of age"
                                "25-29 years of age",
                                "30-34 years of age",
                                "35-39 years of age",
                                "40-44 years of age",
                                "45-49 years of age",
                                "50-54 years of age",
                                "55-59 years of age",
                                "60-64 years of age"
                                ]))\
      ]

df_involuntary_part_time = df_involuntary_part_time[["REGION_2D", "YEAR", "Population (inferred)"]].rename(
    columns={
        "REGION_2D":"geo",
        "YEAR":"year",
        "Population (inferred)":"involuntary_part_time",
    }
    )
df_involuntary_part_time = df_involuntary_part_time.groupby(by=["geo","year"]).sum().reset_index()
df_involuntary_part_time
df_involuntary_part_time.to_csv(SAVE_FILENAME, index=False)

# ## Involuntary Temporary Employment
## Input data
FILENAME_TEMP = "microdata__Multi_Years_Country_Group_REGION_2D-TEMP-TEMPREAS__Target_AGE_GRP.csv"

## Output data
SAVE_FILENAME_TEMP = "NUTS2_Involuntary_Temporary_Employment.csv"
df_temp = pd.read_csv(FILENAME_TEMP)
df_temp
df_temp["TEMP"].value_counts()
df_temp["TEMPREAS"].value_counts()
df_temp["AGE_GRP"].value_counts()
df_involuntary_temporary = df_temp[\
      (df_temp["TEMP"]=="Fixed-term job")&\
      (df_temp["TEMPREAS"]=="Could not find a permanent job")&\
      (df_temp["AGE_GRP"].isin(["15-19 years of age",
                                "20-24 years of age"
                                "25-29 years of age",
                                "30-34 years of age",
                                "35-39 years of age",
                                "40-44 years of age",
                                "45-49 years of age",
                                "50-54 years of age",
                                "55-59 years of age",
                                "60-64 years of age"
                                ]))\
       ]
df_involuntary_temporary = df_involuntary_temporary[["REGION_2D", "YEAR", "Population (inferred)"]].rename(
    columns={
        "REGION_2D":"geo",
        "YEAR":"year",
        "Population (inferred)":"involuntary_temporary",
    }
    )
df_involuntary_temporary = df_involuntary_temporary.groupby(by=["geo","year"]).sum().reset_index()
df_involuntary_temporary
df_involuntary_temporary.to_csv(SAVE_FILENAME_TEMP, index=False)

# # Full-time / Part-time / Temporary (not involuntary)
SAVE_FILENAME_FT = "NUTS2_Full_Time_Employment.csv"

df_part_time = df_ftpt[\
      (df_ftpt["FTPT"]=="Full-time job")&\
      # (df_ftpt["FTPTREAS"]=="Could not find a full-time job")&\
      (df_ftpt["AGE_GRP"].isin(["15-19 years of age",
                                "20-24 years of age"
                                "25-29 years of age",
                                "30-34 years of age",
                                "35-39 years of age",
                                "40-44 years of age",
                                "45-49 years of age",
                                "50-54 years of age",
                                "55-59 years of age",
                                "60-64 years of age"
                                ]))\
      ]

df_part_time = df_part_time[["REGION_2D", "YEAR", "Population (inferred)"]].rename(
    columns={
        "REGION_2D":"geo",
        "YEAR":"year",
        "Population (inferred)":"full_time",
    }
    )
df_part_time = df_part_time.groupby(by=["geo","year"]).sum().reset_index()
df_part_time.to_csv(SAVE_FILENAME_FT, index=False)
df_part_time
SAVE_FILENAME_PT = "NUTS2_Part_Time_Employment.csv"

df_part_time = df_ftpt[\
      (df_ftpt["FTPT"]=="Part-time job")&\
      # (df_ftpt["FTPTREAS"]=="Could not find a full-time job")&\
      (df_ftpt["AGE_GRP"].isin(["15-19 years of age",
                                "20-24 years of age"
                                "25-29 years of age",
                                "30-34 years of age",
                                "35-39 years of age",
                                "40-44 years of age",
                                "45-49 years of age",
                                "50-54 years of age",
                                "55-59 years of age",
                                "60-64 years of age"
                                ]))\
      ]

df_part_time = df_part_time[["REGION_2D", "YEAR", "Population (inferred)"]].rename(
    columns={
        "REGION_2D":"geo",
        "YEAR":"year",
        "Population (inferred)":"part_time",
    }
    )
df_part_time = df_part_time.groupby(by=["geo","year"]).sum().reset_index()
df_part_time.to_csv(SAVE_FILENAME_PT, index=False)
df_part_time
SAVE_FILENAME_TE = "NUTS2_Temporary_Employment.csv"
df_temporary = df_temp[\
      (df_temp["TEMP"]=="Fixed-term job")&\
      # (df_temp["TEMPREAS"]=="Could not find a permanent job")&\
      (df_temp["AGE_GRP"].isin(["15-19 years of age",
                                "20-24 years of age"
                                "25-29 years of age",
                                "30-34 years of age",
                                "35-39 years of age",
                                "40-44 years of age",
                                "45-49 years of age",
                                "50-54 years of age",
                                "55-59 years of age",
                                "60-64 years of age"
                                ]))\
       ]
df_temporary = df_temporary[["REGION_2D", "YEAR", "Population (inferred)"]].rename(
    columns={
        "REGION_2D":"geo",
        "YEAR":"year",
        "Population (inferred)":"temporary",
    }
    )
df_temporary = df_temporary.groupby(by=["geo","year"]).sum().reset_index()
df_temporary.to_csv(SAVE_FILENAME_TE, index=False)
df_temporary
SAVE_FILENAME_PE = "NUTS2_Permanent_Employment.csv"
df_temporary = df_temp[\
      (df_temp["TEMP"]=="Permanent job")&\
      # (df_temp["TEMPREAS"]=="Could not find a permanent job")&\
      (df_temp["AGE_GRP"].isin(["15-19 years of age",
                                "20-24 years of age"
                                "25-29 years of age",
                                "30-34 years of age",
                                "35-39 years of age",
                                "40-44 years of age",
                                "45-49 years of age",
                                "50-54 years of age",
                                "55-59 years of age",
                                "60-64 years of age"
                                ]))\
       ]
df_temporary = df_temporary[["REGION_2D", "YEAR", "Population (inferred)"]].rename(
    columns={
        "REGION_2D":"geo",
        "YEAR":"year",
        "Population (inferred)":"permanent",
    }
    )
df_temporary = df_temporary.groupby(by=["geo","year"]).sum().reset_index()
df_temporary.to_csv(SAVE_FILENAME_PE, index=False)

