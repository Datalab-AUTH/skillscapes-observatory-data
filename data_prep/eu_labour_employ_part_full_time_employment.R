#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_part_full_time_employment <- get_eurostat('lfst_r_lfe2eftpt',
                                                      filters = list(
                                                        wstatus = 'SAL',
                                                        age = 'Y15-64',
                                                        sex = 'T',
                                                        worktime = c('FT', 'PT')
                                                      ),
                                                      time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age, -wstatus) |>
  mutate(values = 1000 * values) |>
  pivot_wider(names_from = worktime, values_from = values) |>
  rename(
    "year" = "time",
    "employment_part_time" = "PT",
    "employment_full_time" = "FT"
  ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    employment_part_time = as.integer(employment_part_time),
    employment_full_time = as.integer(employment_full_time)
  )

dbWriteTable(con_sqlite, "eu_labour_part_full_time_employment", d_eu_labour_part_full_time_employment, overwrite = TRUE)

