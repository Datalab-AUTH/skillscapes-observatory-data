#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_economy_gfcf <- get_eurostat('nama_10r_2gfcf',
                  filters = list(
                    currency = 'MIO_EUR', # million euros
                    nace_r2 = 'TOTAL', # all NACE activities
                    sector = 'S1' # Total economy
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -nace_r2, -sector, -currency) |>
  rename(
    "year" = "time",
    "gfcf" = "values") |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    gfcf = as.numeric(gfcf)
  )

dbWriteTable(con_sqlite, "eu_economy_gfcf", d_eu_economy_gfcf, overwrite = TRUE)

