#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_unemployment_rate <- get_eurostat('lfst_r_lfu3rt',
                  filters = list(
                    age = 'Y15-74',
                    sex = 'T',
                    isced11 = 'TOTAL'
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age, -isced11) |>
  rename(
    "year" = "time",
    "unemployment_rate" = "values"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_unemployment_rate", d_eu_labour_unemployment_rate, overwrite = TRUE)

