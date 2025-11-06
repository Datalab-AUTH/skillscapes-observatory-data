#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_tourism_eu_gfcf <- get_eurostat('nama_10r_2gfcf',
                                     filters = list(
                                       currency = "MIO_EUR",
                                       sector = "S1",
                                       nace_r2 = "G-I"
                                     ),
                                     time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -currency, -sector, -nace_r2) |>
  rename(
    "year" = "time",
    "gfcf_sector_ghi" = "values"
  ) |>
  mutate(
    year = as.integer(year)
  ) |>
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_tourism_eu_gfcf", d_eu_tourism_eu_gfcf, overwrite = TRUE)

