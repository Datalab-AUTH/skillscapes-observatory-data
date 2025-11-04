#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_labour_force <- get_eurostat('lfst_r_lfp2act',
                  filters = list(
                    age = 'Y15-64',
                    sex = 'T'
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age) |>
  rename(
    "year" = "time",
    "labour_force" = "values"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    labour_force = as.integer(1000 * labour_force)
  )

dbWriteTable(con_sqlite, "eu_labour_labour_force", d_eu_labour_labour_force, overwrite = TRUE)

