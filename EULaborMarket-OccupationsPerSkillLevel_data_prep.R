#!/usr/bin/Rscript

library(tidyverse)
library(eurostat)
library(readxl)

d_population_NUTS2 <- get_eurostat('demo_r_pjangroup',
                                   filters = list(
                                     age = "TOTAL",
                                     sex = "T"
                                   ),
                                   time_format = "num", stringsAsFactors = TRUE) |>
  filter(time >= 2008) |>
  select(-freq, -age, -sex, -unit ) |>
  rename("population" = "values") |>
  rename("year" = "time") 

d_country <- read_csv("data_csv/SS21_countries.csv") |>
  select(-Period) |>
  rename(
    ISCO08 = isco08_1d,
    "Country_code" = "NUTS code",
    "geo" = "NUTS name"
  ) |>
  filter(
    ISCO08 != "Not stated",
    Country_code != '_T'
  ) |>
  mutate(
    value = 1000 * value,
    age = recode(age,
                 "15 - 29 years" = "15-29",
                 "15 - 64 years" = "15-64",
                 "30 - 64 years" = "30-64",
                 "15-64 years" = "15-64",
                 "30-64 years" = "30-64",
                 "15-29 years" = "15-29"
    ),
    ISCO08 = recode(ISCO08,
                    "ISCO_4-5_low skilled non-manual" = "4-5",
                    "ISCO 6-8_skilled manual" = "6-8",
                    "ISCO_9_elementary occupations" = "9",
                    "ISCO_0_armed forces occupations" = "10",
                    "ISCO_1-3_highly skilled non-manual" = "1-3",
                    "Armed forces" = "10",
                    "ISCO_1-3" = "1-3",
                    "ISCO_9" = "9",
                    "ISCO_6-8" = "6-8",
                    "ISCO_4-5" = "4-5"
    ),
    ISCO08 = factor(ISCO08, levels = c("1-3", "4-5", "6-8", "9", "10"))
  ) |>
  rename(
    "year" = "Year",
    "skill_level" = "ISCO08"
    )
  
  left_join(d_population_by_country, by=c("Country_Code", "Year")) |>
  mutate(value_pct = 100 * value / Population) |>
  arrange(Country, Year) |>
  group_by(Country) |>
  mutate(
    value_prev = lag(value),
    value_pct_diff = ifelse(is.na(value_prev), NA, ((value - value_prev) / value_prev) * 100)
  )
d_NUTS2 <- read_csv("data_csv/SS21_NUTS2.csv") |>
  select(-Period) |>
  rename(
    ISCO08 = isco08_1d,
    "NUTS_Code" = "NUTS code",
    "NUTS_Name" = "NUTS name"
  ) |>
  filter(
    ISCO08 != "Not stated",
    NUTS_Code != '_TO'
  ) |>
  mutate(
    value = 1000 * value,
    age = recode(age,
                 "15 - 29 years" = "15-29",
                 "15 - 64 years" = "15-64",
                 "30 - 64 years" = "30-64",
                 "15-64 years" = "15-64",
                 "30-64 years" = "30-64",
                 "15-29 years" = "15-29"
    ),
    ISCO08 = recode(ISCO08,
                    "ISCO_4-5_low skilled non-manual" = "4-5",
                    "ISCO 6-8_skilled manual" = "6-8",
                    "ISCO_9_elementary occupations" = "9",
                    "ISCO_0_armed forces occupations" = "10",
                    "ISCO_1-3_highly skilled non-manual" = "1-3",
                    "Armed forces" = "10",
                    "ISCO_1-3" = "1-3",
                    "ISCO_9" = "9",
                    "ISCO_6-8" = "6-8",
                    "ISCO_4-5" = "4-5"
    ),
    ISCO08 = factor(ISCO08, levels = c("1-3", "4-5", "6-8", "9", "10" )),
    Country_Code = str_sub(NUTS_Code, 1, 2)
  )
d_NUTS1_names <- read_excel("data_original/NUTS2021-NUTS2024.xlsx") |>
  filter(`NUTS level` == 1) |>
  select("Country code", "NUTS Code", "NUTS label") |>
  rename(
    "Country_Code" = "Country code",
    "NUTS_Code" = "NUTS Code",
    "NUTS_Name" = "NUTS label"
  )
d_NUTS1 <- d_NUTS2 |>
  mutate(NUTS1 = str_sub(NUTS_Code, 1, 3)) |>
  group_by(NUTS1, Year, age, ISCO08) |>
  summarize(value = sum(value, na.rm=TRUE)) |>
  rename("NUTS_Code" = "NUTS1") |>
  left_join(d_NUTS1_names, by="NUTS_Code") |>
  rename("NUTS1" = "NUTS_Code") |>
  left_join(d_population_by_NUTS1, by=c("NUTS1", "Year")) |>
  mutate(value_pct = 100* value / value) |>
  arrange(NUTS1, Year) |>
  group_by(NUTS1) |>
  mutate(
    value_prev = lag(value),
    value_pct_diff = ifelse(is.na(value_prev), NA, ((value - value_prev) / value_prev) * 100)
  ) |>
  filter(NUTS1 != "_TO")
d_NUTS2 <- d_NUTS2 |>
  rename("NUTS2" = "NUTS_Code") |>
  left_join(d_population_by_NUTS2, by=c("NUTS2", "Year")) |>
  mutate(value_pct = 100 * value / Population) |>
  arrange(NUTS2, Year) |>
  group_by(NUTS2) |>
  mutate(
    value_prev = lag(value),
    value_pct_diff = ifelse(is.na(value_prev), NA, ((value - value_prev) / value_prev) * 100)
  ) |>
  filter(NUTS2 != "_TOTAL")
