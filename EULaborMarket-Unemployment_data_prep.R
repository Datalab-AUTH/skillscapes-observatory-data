#!/usr/bin/Rscript

library(tidyverse)
library(readxl)
library(eurostat)

d <- get_eurostat('tgs00010',
                  filters = list(
                    isced11 = "TOTAL",
                    age = "Y15-74",
                    sex = "T"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -age, -unit, -sex, -isced11 ) |>
  rename("unemployment_pct" = "values") |>
  rename("year" = "time")
d_NUTS_codes <- read_excel("data/NUTS2021-NUTS2024.xlsx") |>
  rename(
    "geo" = "NUTS Code",
    "geo_label" = "NUTS label",
    "NUTS_level" = "NUTS level",
    "Country_code" = "Country code"
  ) |>
  select(-"Country order", -"#")
d_countries <- rbind(eu_countries, ea_countries, efta_countries, eu_candidate_countries) |>
  distinct() |>
  select(-label) |>
  rename(
    "geo_label" = "name",
    "geo" = "code"
  ) |>
  mutate (
    "NUTS_level" = 0,
    "Country_code" = geo
  )
d_regions <- rbind(d_countries, d_NUTS_codes)
d_unemployment <- d |>
  left_join(d_regions, by="geo") |>
  filter(!is.na(geo_label)) |>
  arrange("geo", "year") |>
  group_by(geo) |>
  mutate(
    unemployment_pct_prev = lag(unemployment_pct),
    unemployment_diff = ifelse(is.na(unemployment_pct_prev), NA, ((unemployment_pct - unemployment_pct_prev) / unemployment_pct_prev) * 100
    )) |>
  select(-unemployment_pct_prev)

write_csv(d_unemployment, "data/EU_labor_market_unemployment.csv")
