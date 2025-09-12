#!/usr/bin/Rscript

library(tidyverse)
library(eurostat)
library(readxl)

d <- get_eurostat('lfst_r_lfe2en2',
                  filters = list(
                    nace_r2 = "TOTAL",
                    age = "Y15-74",
                    sex = "T"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -nace_r2, -age, -sex, -unit ) |>
  mutate(values = 1000 * values) |>
  rename("total_employment" = "values") |>
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
d <- d |>
  left_join(d_regions, by="geo") |>
  filter(!is.na(geo_label)) |>
  arrange("geo", "year") |>
  group_by(geo) |>
  mutate(
    total_employment_prev = lag(total_employment),
    total_employment_pct_diff = ifelse(is.na(total_employment_prev), NA, ((total_employment - total_employment_prev) / total_employment_prev) * 100
    )) |>
  select(-total_employment_prev) |>
  relocate(geo_label, .after=geo) |>
  relocate(NUTS_level, .after=geo_label) |>
  relocate(Country_code, .after=NUTS_level) |>
  ungroup()

d_population_countries <- get_eurostat('demo_pjan',
                    filters = list(
                      age = "TOTAL",
                      sex = "T"
                    ),
                    time_format = "num", stringsAsFactors = TRUE) |>
  filter(time >= 2008) |>
  select(-freq, -age, -sex, -unit ) |>
  mutate(values = 1000 * values) |>
  rename("population" = "values") |>
  rename(
    "year" = "time",
    "Country_code" = "geo")

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

d_all <- d |>
  left_join(d_population_NUTS2, by=c("geo", "year")) |>
  mutate(employed_pct = 100 * total_employment / population) 

write_csv(d_all, "data/EULaborMarket-TotalEmployment.csv")
