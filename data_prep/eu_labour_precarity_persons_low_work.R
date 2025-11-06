#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_precarity_persons_low_work <- get_eurostat('ilc_lvhl21n',
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit) |>
  rename(
    "year" = "TIME_PERIOD",
    "persons_low_work" = "values"
  ) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_precarity_persons_low_work", d_eu_labour_precarity_persons_low_work, overwrite = TRUE)

