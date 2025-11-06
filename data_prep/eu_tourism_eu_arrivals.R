#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_tourism_eu_arrivals <- get_eurostat('tour_occ_arn2',
                                         filters = list(
                                           c_resid = "TOTAL",
                                           nace_r2 = "I551-I553"
                                         ),
                                         time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -c_resid,  -nace_r2) |>
  rename(
    "year" = "time",
    "arrivals" = "values"
  ) |>
  mutate(
    year = as.integer(year),
    arrivals = as.integer(arrivals)
  ) |>
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_tourism_eu_arrivals", d_eu_tourism_eu_arrivals, overwrite = TRUE)

