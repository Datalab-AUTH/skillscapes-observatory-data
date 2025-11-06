#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
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
    short_stay = as.integer(short_stay)
  ) |>
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_tourism_eu_short_stay", d_eu_tourism_eu_short_stay, overwrite = TRUE)

