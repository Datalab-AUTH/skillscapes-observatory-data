#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

if (!exists('d_permanent_temporary_employment')) {
  source('eu_labour_permanent_temporary_employment.R')
}

d_involuntary_part_time_employment <- read_csv("involuntary_employment/NUTS2_Involuntary_Part_Time_Employment.csv")
d_involuntary_temporary_employment <- read_csv("involuntary_employment/NUTS2_Involuntary_Temporary_Employment.csv")

d_involuntary_employment <- d_involuntary_part_time_employment |>
  full_join(d_involuntary_temporary_employment, by=c("geo", "year")) |>
  mutate(year = as.integer(year)) |>
  left_join(d_permanent_temporary_employment, by=c("geo", "year")) |>
  left_join(d_eu_labour_part_full_time_employment, by=c("geo", "year")) |>
  mutate(
    involuntary_temporary_pct = 100 * involuntary_temporary / temporary_employment,
    involuntary_part_time_pct = 100 * involuntary_part_time / employment_part_time
  ) |>
  select(geo, year, starts_with("involuntary"))

dbWriteTable(con_sqlite, "eu_labour_precarity_involuntary_employment", d_involuntary_employment, overwrite = TRUE)
