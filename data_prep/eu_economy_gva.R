#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_economy_gva <- get_eurostat('nama_10r_3gva',
                  filters = list(
                    unit = 'CP_MEUR', # total, million euros
                    nace_r2 = 'TOTAL' # all NACE activities
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -nace_r2,-unit) |>
  rename(
    "year" = "time",
    "gva" = "values") |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    gva = as.integer(gva)
  )

dbWriteTable(con_sqlite, "eu_economy_gva", d_eu_economy_gva, overwrite = TRUE)

