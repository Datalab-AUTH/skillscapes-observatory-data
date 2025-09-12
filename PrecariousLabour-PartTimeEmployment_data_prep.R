#!/usr/bin/Rscript

library(tidyverse)
library(readxl)
library(eurostat)

d <- get_eurostat('lfst_r_lfe2eftpt',
                  filters = list(
                    age = "Y15-64",
                    worktime = "PT",
                    wstatus = "EMP",
                    sex = "T"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -worktime, -wstatus, -age, -unit, -sex ) |>
  rename("part_time_employment" = "values") |>
  rename("year" = "time") |>
  mutate(part_time_employment = 1000 * part_time_employment)
d_population <- get_eurostat("demo_r_pjangroup",
                             filters = list(
                               age = "TOTAL",
                               sex = "T"
                             ),
                             time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age) |>
  rename(
    "year" = "time",
    "population" = "values"
  )
d <- d |>
  left_join(d_population, by = c("geo", "year"))
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
d_part_time <- d |>
  left_join(d_regions, by="geo") |>
  filter(!is.na(geo_label)) |>
  arrange("geo", "year") |>
  group_by(geo) |>
  mutate(
    part_time_employment_pct = 100 * part_time_employment / population,
    part_time_employment_prev = lag(part_time_employment),
    part_time_employment_diff = ifelse(is.na(part_time_employment_prev), NA, ((part_time_employment - part_time_employment_prev) / part_time_employment_prev) * 100
    )) |>
  select(-part_time_employment_prev)
write_csv(d_part_time, "data/precarious_part_time_employment.csv")
