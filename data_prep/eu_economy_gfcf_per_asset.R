#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_economy_gfcf_per_asset <- get_eurostat('nama_10_an6',
                                  filters = list(
                                    unit = "CP_MEUR"
                                  ),
                                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit) |>
  pivot_wider(names_from = asset10, values_from = values) |>
  rename("year" = "time") |>
  rename_with(~ paste0("gfcf_", .x), starts_with("N")) |>
  mutate(
    year = as.integer(year)
  ) |>
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_economy_gfcf_per_asset", d_eu_economy_gfcf_per_asset, overwrite = TRUE)

