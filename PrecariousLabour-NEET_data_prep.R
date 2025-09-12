#!/usr/bin/Rscript

library(tidyverse)
library(readxl)
library(eurostat)

d <- get_eurostat('edat_lfse_22', time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -training, -unit, -wstatus) |>
  rename("unemployment_rate" = "values") |>
  filter(
    age == "Y15-29",
    sex == "T"
  )
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
d_population <- get_eurostat("demo_r_pjangroup", time_format = "num", stringsAsFactors = TRUE) |>
  mutate(age = recode(age,
                      "Y15-19" = "Y15-29",
                      "Y20-24" = "Y15-29",
                      "Y25-29" = "Y15-29"
  )) |>
  filter(sex == "T") |>
  select(-freq, -unit, -sex)
d_population_15_29 <- d_population |>
  filter(age == "Y15-29") |>
  select(-age) |>
  rename("population_15_29" = "values")
d_population_total <- d_population |>
  filter(age == 'TOTAL') |>
  select(-age) |>
  rename("population_total" = "values")
# This is the complete dataset now
d_NEET <- d |>
  left_join(d_regions, by="geo") |>
  select(-age, -sex) |>
  filter(!is.na(geo_label)) |>
  rename("year" = "TIME_PERIOD") |>
  arrange("geo", "year") |>
  group_by(geo) |>
  mutate(
    unemployment_rate_prev = lag(unemployment_rate),
    unemployment_rate_pct_diff = ifelse(is.na(unemployment_rate_prev), NA, ((unemployment_rate - unemployment_rate_prev) / unemployment_rate_prev) * 100
    )) |>
  select(-unemployment_rate_prev)
#|>
#left_join(d_population_15_29, by=c("geo", "TIME_PERIOD")) |>
#left_join(d_population_total, by=c("geo", "TIME_PERIOD"))
write_csv(d_NEET, "data/precarious_NEET.csv")