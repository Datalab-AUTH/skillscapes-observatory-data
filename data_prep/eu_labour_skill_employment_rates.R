#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_labour_skill_employment_rates <- get_eurostat('lfst_r_lfe2emprtn',
                  filters = list(
                    citizen = "TOTAL",
                    age = "Y15-64",
                    sex = "T",
                    isced11 = c("ED0-2", "ED3_4", "ED5-8")
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -unit, -sex, -age, -citizen) |>
  pivot_wider(names_from = isced11, values_from = values) |>
  rename(
    "year" = "time",
    "empl_rate_ED0-2" = "ED0-2",
    "empl_rate_ED3-4" = "ED3_4",
    "empl_rate_ED5-8" = "ED5-8"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
  )

dbWriteTable(con_sqlite, "eu_labour_skill_employment_rates", d_eu_labour_skill_employment_rates, overwrite = TRUE)

