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

d_eu_tourism_eu_bed_places <- get_eurostat('tour_cap_nuts2',
                                           filters = list(
                                             accomunit =  c("ESTBL", "BEDPL"),
                                             nace_r2 = "I551-I553",
                                             unit = "NR"
                                           ),
                                           time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -nace_r2) |>
  pivot_wider(names_from = accomunit, values_from = values) |>
  rename(
    "year" = "time",
    "establishments" = "ESTBL",
    "bed_places" = "BEDPL"
  ) |>
  mutate(
    year = as.integer(year),
    establishments = as.integer(establishments),
    bed_places = as.integer(bed_places)
  ) |>
  filter(year >= 2008) |>
  left_join(d_gen_population, by=c("geo", "year")) |>
  left_join(d_gen_land_area, by=c("geo", "year")) |>
  mutate(
    bed_places_per_1k_persons = 1000 * bed_places / population_total,
    bed_places_per_1k_persons = ifelse(is.infinite(bed_places_per_1k_persons), NA, bed_places_per_1k_persons), # there are zeros in the population_total data
    bed_places_per_km2 = bed_places / land_area,
    establishments_per_1k_persons = 1000 * establishments / population_total,
    establishments_per_1k_persons = ifelse(is.infinite(establishments_per_1k_persons), NA, establishments_per_1k_persons), # there are zeros in the population_total data
    establishments_per_km2 = establishments / land_area
  ) |>
  select(-starts_with("population"), -land_area)

dbWriteTable(con_sqlite, "eu_tourism_eu_bed_places", d_eu_tourism_eu_bed_places, overwrite = TRUE)

