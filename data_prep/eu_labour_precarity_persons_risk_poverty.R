#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_precarity_persons_risk_poverty <- get_eurostat('ilc_li41',
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit) |>
  rename(
    "year" = "TIME_PERIOD",
    "persons_risk_poverty" = "values"
  ) |>
  mutate(
    year = as.integer(year)
  ) |>
  filter(year >= 2008)

dbWriteTable(con_sqlite, "eu_labour_precarity_persons_risk_poverty", d_eu_labour_precarity_persons_risk_poverty, overwrite = TRUE)

