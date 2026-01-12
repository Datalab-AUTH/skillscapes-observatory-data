#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_long_term_unemployment <- get_eurostat('lfst_r_lfu2ltu',
                                         filters = list(
                                           isced11 = 'TOTAL',
                                           age = 'Y15-74',
                                           sex = 'T'
                                         ),
                                         time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -isced11, -sex, -age) |>
  filter(unit == "THS_PER" | unit == "PC_UNE") |>
  pivot_wider(names_from = "unit", values_from = "values") |>
  rename(
    "year" = "time",
    "long_term_unemployment" = "THS_PER",
    "long_term_unemployment_rate" = "PC_UNE"
  ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    long_term_unemployment = 1000 * long_term_unemployment
  )

dbWriteTable(con_sqlite, "eu_labour_long_term_unemployment", d_eu_labour_long_term_unemployment, overwrite = TRUE)

