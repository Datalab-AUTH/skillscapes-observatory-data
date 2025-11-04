#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_weekly_hours <- get_eurostat('lfst_r_lfe2ehour',
                  filters = list(
                    age = 'Y15-64',
                    sex = 'T'
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age) |>
  rename(
    "year" = "time",
    "weekly_hours" = "values"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_weekly_hours", d_eu_labour_weekly_hours, overwrite = TRUE)

