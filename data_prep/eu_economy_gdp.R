#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_eu_economy_gdp <- get_eurostat('nama_10r_2gdp',
                  filters = list(
                    unit = c('MIO_EUR', 'EUR_HAB')
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq) |>
  pivot_wider(names_from = unit, values_from = values) |>
  rename(
    "year" = "time",
    "gdp_mio_eur" = "MIO_EUR",
    "gdp_eur_hab" = "EUR_HAB"
    ) |>
  filter(year >= 2008) |>
  mutate(
    year = as.integer(year),
    gdp_mio_eur = as.integer(gdp_mio_year),
    gdp_eur_hab = as.integer(gdp_eur_hab)
  )

dbWriteTable(con_sqlite, "eu_economy_gdp", d_eu_economy_gdp, overwrite = TRUE)

