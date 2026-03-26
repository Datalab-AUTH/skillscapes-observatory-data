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
                                    currency = "MIO_EUR",
                                    sector = "S1"
                                  ),
                                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -currency, -sector) |>
  pivot_wider(names_from = nace_r2, values_from = values) |>
  rename(
    "year" = "time",
    "gfcf" = "TOTAL",
    "gcfc_sector_a" = "A",
    "gcfc_sector_bcde" = "B-E",
    "gcfc_sector_c" = "C",
    "gcfc_sector_f" = "F",
    "gcfc_sector_ghij" = "G-J",
    "gcfc_sector_ghi" = "G-I",
    "gcfc_sector_j" = "J",
    "gcfc_sector_klmn" = "K-N",
    "gcfc_sector_k" = "K",
    "gcfc_sector_l" = "L",
    "gcfc_sector_mn" = "M_N",
    "gcfc_sector_opqrstu" = "O-U",
    "gcfc_sector_opq" = "O-Q",
    "gcfc_sector_rstu" = "R-U"
  ) |>
  mutate(
    year = as.integer(year)
  ) |>
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_economy_gfcf", d_eu_economy_gfcf, overwrite = TRUE)

