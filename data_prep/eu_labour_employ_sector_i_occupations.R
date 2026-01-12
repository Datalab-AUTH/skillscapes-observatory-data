#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_sector_i_occupation <- get_eurostat('lfsa_eisn2',
                                      filters = list(
                                        age = 'Y20-64',
                                        sex = 'T',
                                        nace_r2 = 'I' # accomodation and food services
                                      ),
                                      time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age, -nace_r2) |>
  mutate(
    values = as.integer(1000 * values),
    isco08 = paste0("sector_i_employment_", isco08)
  ) |>
  pivot_wider(names_from = isco08, values_from = values) |>
  rename(
    "year" = "time"
  ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_sector_i_occupation", d_eu_labour_sector_i_occupation, overwrite = TRUE)

