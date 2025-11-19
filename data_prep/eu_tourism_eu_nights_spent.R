#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
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
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_tourism_eu_nights_spent", d_eu_tourism_eu_nights_spent, overwrite = TRUE)

