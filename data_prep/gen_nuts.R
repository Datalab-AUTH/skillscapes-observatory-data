#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_gen_nuts <- get_eurostat_dic('geo') |>
  rename(
    geo = code_name,
    geo_label = full_name
    ) |>
  recode_nuts('geo') |>
  filter(typology != 'invalid_typology') |>
  rename(nuts_level = typology) |>
  select(geo, geo_label, nuts_level) |>
  mutate(nuts_level =
           recode(nuts_level,
                 "country" = "0",
                 "nuts_level_1" = "1",
                 "nuts_level_2" = "2",
                 "nuts_level_3" = "3"
                 ),
         nuts_level = as.integer(nuts_level),
         country_code = str_sub(geo, 1, 2),
    )
d_countries <- d_gen_nuts |>
  filter(geo == country_code) |>
  rename(
    country_name = geo_label
  ) |>
  select(country_code, country_name)
d_gen_nuts <- d_gen_nuts |>
  left_join(d_countries, by='country_code')

dbWriteTable(con_sqlite, "gen_nuts", d_gen_nuts, overwrite = TRUE)

