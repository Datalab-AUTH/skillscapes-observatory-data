#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_youth_unemployment <- get_eurostat('lfst_r_lfu3pers',
                  filters = list(
                    age = 'Y15-29',
                    sex = 'T',
                    isced11 = "TOTAL"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age, -isced11) |>
  rename(
    "year" = "time",
    "youth_unemployment" = "values"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    youth_unemployment = as.integer(1000 * youth_unemployment)
  )

dbWriteTable(con_sqlite, "eu_labour_youth_unemployment", d_eu_labour_youth_unemployment, overwrite = TRUE)

