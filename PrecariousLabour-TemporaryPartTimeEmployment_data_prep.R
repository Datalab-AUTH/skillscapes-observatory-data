#!/usr/bin/Rscript

library(tidyverse)
library(readxl)
library(eurostat)

d <- get_eurostat('lfsa_etpgacob',
                  filters = list(
                    c_birth = "TOTAL",
                    age = "Y15-74",
                    sex = "T"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -age, -unit, -sex, -c_birth ) |>
  rename("temporary_employment" = "values") |>
  rename("year" = "time")
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
d_part_time <- d |>
  left_join(d_countries, by="geo") |>
  filter(!is.na(geo_label)) |>
  arrange("geo", "year") |>
  group_by(geo) |>
  mutate(
    temporary_employment_prev = lag(temporary_employment),
    temporary_employment_diff = ifelse(is.na(temporary_employment_prev), NA, ((temporary_employment - temporary_employment_prev) / temporary_employment_prev) * 100
    )) |>
  select(-temporary_employment_prev)
write_csv(d_part_time, "data/precarious_temporary_part_time_employment.csv")
