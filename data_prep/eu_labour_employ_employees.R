#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_employees <- get_eurostat('lfst_r_lfe2estat',
                                      filters = list(
                                        wstatus = c('SAL', 'SELF', 'SELF_S', 'SELF_NS', 'CFAM'),
                                        age = 'Y15-64',
                                        sex = 'T'
                                      ),
                                      time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age) |>
  mutate(values = as.integer(1000 * values)) |>
  pivot_wider(names_from = wstatus, values_from = values) |>
  rename(
    "year" = "time",
    "employees" = "SAL",
    "self_employed" = "SELF",
    "self_employed_with_employees" = "SELF_S",
    "self_employed_without_employees" = "SELF_NS",
    "contributing_family_members" = "CFAM"
  ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_employees", d_eu_labour_employees, overwrite = TRUE)

