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
                    unit = 'CP_MEUR' # total, million euros
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq,-unit) |>
  pivot_wider(names_from=nace_r2, values_from = values) |>
  rename(
    "year" = "time",
    "gva" = "TOTAL",
    "gva_sector_a" = "A",
    "gva_sector_bde" = "B-E",
    "gva_sector_c" = "C",
    "gva_sector_f" = "F",
    "gva_sector_ghij" = "G-J",
    "gva_sector_ghi" = "G-I",
    "gva_sector_j" = "J",
    "gva_sector_klmn" = "K-N",
    "gva_sector_k" = "K",
    "gva_sector_l" = "L",
    "gva_sector_mn" = "M_N",
    "gva_sector_opqrstu" = "O-U",
    "gva_sector_opq" = "O-Q",
    "gva_sector_rstu" = "R-U"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    gva = as.integer(gva)
  )

dbWriteTable(con_sqlite, "eu_economy_gva", d_eu_economy_gva, overwrite = TRUE)

