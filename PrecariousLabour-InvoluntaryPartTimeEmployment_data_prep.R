#!/usr/bin/Rscript

library(tidyverse)
library(readxl)
library(eurostat)

d <- get_eurostat('lfsa_eppgai',
                  filters = list(
                    age = "Y15-74",
                    sex = "T"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -age, -unit, -sex ) |>
  rename("involuntary_part_time_employment" = "values") |>
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
    involuntary_part_time_employment_prev = lag(involuntary_part_time_employment),
    involuntary_part_time_employment_diff = ifelse(is.na(involuntary_part_time_employment_prev), NA, ((involuntary_part_time_employment - involuntary_part_time_employment_prev) / involuntary_part_time_employment_prev) * 100
    )) |>
  select(-involuntary_part_time_employment_prev)
write_csv(d_part_time, "data/precarious_involuntary_part_time_employment.csv")
