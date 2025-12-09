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

d_eu_tourism_eu_short_stay <- get_eurostat('tour_ce_omn12',
                                           filters = list(
                                             c_resid = "TOTAL",
                                             month = "TOTAL",
                                             indic_to =  "NGT_SP"
                                           ),
                                           time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -c_resid, -month, -indic_to) |>
  rename(
    "year" = "time",
    "short_stay" = "values"
  ) |>
  mutate(
    year = as.integer(year),
    short_stay = short_stay
  ) |>
  filter(year >= 2008) |>
  left_join(d_gen_population, by=c("geo", "year")) |>
  left_join(d_gen_land_area, by=c("geo", "year")) |>
  mutate(
    short_stay_per_person = short_stay / population_total,
    short_stay_per_person = ifelse(is.infinite(short_stay_per_person), NA, short_stay_per_person), # there are zeros in the population_total data
    short_stay_per_km2 = short_stay / land_area
  ) |>
  select(-starts_with("population"), -land_area)

dbWriteTable(con_sqlite, "eu_tourism_eu_short_stay", d_eu_tourism_eu_short_stay, overwrite = TRUE)

