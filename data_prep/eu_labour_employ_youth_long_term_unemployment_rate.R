#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_youth_long_term_unemployment_rate <- get_eurostat('yth_empl_130',
                  filters = list(
                    sex = 'T'
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age) |>
  rename(
    "year" = "time",
    "youth_long_term_unemployment_rate" = "values"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_youth_long_term_unemployment_rate", d_eu_labour_youth_long_term_unemployment_rate, overwrite = TRUE)

