#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

if (!exists('d_eu_labour_employees')) {
  source('eu_labour_employ_employees.R')
}

d_permanent_employment <- read_csv("microdata/NUTS2_Permanent_Employment.csv") |>
  rename(permanent_employment = permanent)
d_temporary_employment <- read_csv("microdata/NUTS2_Temporary_Employment.csv") |>
  rename(temporary_employment = temporary)

d_permanent_temporary_employment <- d_permanent_employment |>
  full_join(d_temporary_employment, by=c("geo", "year")) |>
  mutate(year = as.integer(year)) |>
  left_join(d_eu_labour_employees, by=c("geo", "year")) |>
  mutate(
    permanent_employment_pct = 100 * permanent_employment / employees,
    temporary_employment_pct = 100 * temporary_employment / employees
  ) |>
  select(geo, year, starts_with("permanent"), starts_with("temporary"))

dbWriteTable(con_sqlite, "eu_labour_permanent_temporary_employment", d_permanent_temporary_employment, overwrite = TRUE)
