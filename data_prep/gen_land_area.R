#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_gen_land_area <-  get_eurostat('reg_area3',
                  time_format = "num", stringsAsFactors = TRUE) |>
  filter(landuse == "TOTAL") |>
  select(-freq, -landuse, -unit) |>
  rename(
    "year" = "TIME_PERIOD",
    "land_area" = "values"
  ) |>
  mutate(
    year = as.integer(year),
    land_area = as.integer(land_area)
  )

dbWriteTable(con_sqlite, "gen_land_area", d_gen_land_area, overwrite = TRUE)

