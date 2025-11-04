#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_total_employment <- get_eurostat('lfst_r_lfe2emp',
                  filters = list(
                    age = 'Y15-64',
                    sex = 'T'
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age) |>
  rename(
    "year" = "time",
    "total_employment" = "values"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    total_employment = as.integer(1000 * total_employment)
  )

dbWriteTable(con_sqlite, "eu_labour_total_employment", d_eu_labour_total_employment, overwrite = TRUE)

