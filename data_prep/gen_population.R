#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_gen_population <- get_eurostat('demo_r_d2jan',
                  time_format = "num", stringsAsFactors = TRUE) |>
  filter(
    sex == "T",
    TIME_PERIOD >= 2008
    ) |>
  select(-freq, -unit) |>
  rename("year" = "TIME_PERIOD") |>
  pivot_wider(names_from = age, values_from = values) |>
  select(geo, year, TOTAL, Y15, Y16, Y17, Y18, Y19, Y20, Y21, Y22, Y22, Y23, Y24, Y25, Y26, Y27, Y28, Y29) |>
  mutate(population_15_29 = Y15 + Y16 + Y17 + Y18 + Y19 + Y20 + Y21 + Y22 + Y22 + Y23 + Y24 + Y25 + Y26 + Y27 + Y28 + Y29) |>
  rename("population_total" = "TOTAL") |>
  select(-starts_with('Y', ignore.case=F)) |>
  mutate(
    year = as.integer(year),
    population_total = as.integer(population_total),
    population_15_29 = as.integer(population_15_29)
  )

dbWriteTable(con_sqlite, "gen_population", d_gen_population, overwrite = TRUE)

