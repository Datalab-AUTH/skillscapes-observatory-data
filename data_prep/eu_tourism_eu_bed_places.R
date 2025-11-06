#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
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
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_tourism_eu_bed_places", d_eu_tourism_eu_bed_places, overwrite = TRUE)

