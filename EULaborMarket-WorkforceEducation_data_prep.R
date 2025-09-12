#!/usr/bin/Rscript

library(tidyverse)
library(eurostat)
library(readxl)

d <- get_eurostat('edat_lfse_04',
                      filters = list(
                        sex = "T"
                      ),
                      time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -sex, -unit ) |>
  rename("education_level_pct" = "values") |>
  rename("year" = "time") |>
  filter(
    year >= 2008,
    isced11 != "ED3_4GEN",
    isced11 != "ED3_4VOC",
    isced11 != "ED3-8",
    age == "Y25-64"
  ) |>
  select(-age) |>
  mutate(education_level = case_match(isced11,
    "ED0-2" ~ "low",
    "ED3_4" ~ "medium",
    "ED5-8" ~ "high"
  )) |>
  select(-isced11) |>
  relocate(education_level, .after=year)
  
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

d_all <- d |>
  left_join(d_regions, by="geo") |>
  filter(!is.na(geo_label)) |>
  arrange("geo", "year", "education_level") |>
  group_by(geo, education_level) |>
  mutate(
    education_level_pct_prev = lag(education_level_pct),
    education_level_pct_diff = ifelse(is.na(education_level_pct_prev), NA, ((education_level_pct - education_level_pct_prev) / education_level_pct_prev) * 100
    )) |>
  select(-education_level_pct_prev) |>
  relocate(geo_label, .after=geo) |>
  relocate(NUTS_level, .after=geo_label) |>
  relocate(Country_code, .after=NUTS_level) |>
  ungroup()

write_csv(d_all, "data/EU_labor_market_workforce_education.csv")
