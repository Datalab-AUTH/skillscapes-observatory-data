#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_precarity_deprivation <- get_eurostat('ilc_mdsd18',
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit) |>
  rename(
    "year" = "TIME_PERIOD",
    "deprivation" = "values"
  ) |>
  mutate(
    year = as.integer(year)
  ) |>
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_labour_precarity_deprivation", d_eu_labour_precarity_deprivation, overwrite = TRUE)

