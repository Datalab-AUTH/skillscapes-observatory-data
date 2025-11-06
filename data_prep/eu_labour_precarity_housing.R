#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_precarity_housing <- get_eurostat('ilc_lvho07_r',
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit) |>
  rename(
    "year" = "TIME_PERIOD",
    "housing" = "values"
  ) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_precarity_housing", d_eu_labour_precarity_housing, overwrite = TRUE)

