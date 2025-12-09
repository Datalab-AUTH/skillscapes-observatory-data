#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

if (!exists('d_gen_population')) {
  source('gen_population.R')
}
if (!exists('d_gen_land_area')) {
  source('gen_land_area.R')
}

d_eu_tourism_eu_nights_spent <- get_eurostat('tour_occ_nin2',
                                             filters = list(
                                               unit = "NR",
                                               c_resid = "TOTAL",
                                               nace_r2 = "I551-I553"
                                             ),
                                             time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -c_resid, -nace_r2) |>
  rename(
    "year" = "time",
    "nights_spent" = "values"
  ) |>
  mutate(
    year = as.integer(year),
    nights_spent = as.numeric(nights_spent)
    ) |>
  filter(year >= 2008) |>
  left_join(d_gen_population, by=c("geo", "year")) |>
  left_join(d_gen_land_area, by=c("geo", "year")) |>
  mutate(
    nights_spent_per_person = nights_spent / population_total,
    nights_spent_per_person = ifelse(is.infinite(nights_spent_per_person), NA, nights_spent_per_person), # there are zeros in the population_total data
    nights_spent_per_km2 = nights_spent / land_area
  ) |>
  select(-starts_with("population"), -land_area)

dbWriteTable(con_sqlite, "eu_tourism_eu_nights_spent", d_eu_tourism_eu_nights_spent, overwrite = TRUE)

