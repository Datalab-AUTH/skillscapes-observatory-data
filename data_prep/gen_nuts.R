#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(eurostat)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_gen_nuts_eurostat <- get_eurostat_dic('geo') |>
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
d_countries <- d_gen_nuts_eurostat |>
  filter(geo == country_code) |>
  rename(
    country_name = geo_label
  ) |>
  select(country_code, country_name)

# now, take all the Greek regions that have no NUTS equivalent and join them
# with the ones that do, but are not included in the first list.
d_nuts2_and_region_codes_EL <- read_csv("region_codes_EL.csv")

d_region_codes_only_EL <- d_nuts2_and_region_codes_EL |>
  filter(!str_detect(geo, "\\d$")) |> # only keep regional units, no NUTS3/2
  mutate(
    nuts_level = 4,
    country_code = "EL"
  )

# regional units might be with nuts_level=3 or nuts_level=4, so we need
# something else to tell them apart
d_nuts2_and_region_codes_only_EL <- d_nuts2_and_region_codes_EL |>
  select(geo) |>
  mutate(is_el_regional_unit = 1) 

d_gen_nuts <- d_gen_nuts_eurostat |>
  rbind(d_region_codes_only_EL) |>
  left_join(d_nuts2_and_region_codes_only_EL, by='geo') |>
  left_join(d_countries, by='country_code') |>
  mutate(is_el_regional_unit = if_else(is.na(is_el_regional_unit), 0, is_el_regional_unit)) |>
  relocate(is_el_regional_unit, .after=nuts_level) |>
  mutate(
    nuts_level = as.integer(nuts_level),
    is_el_regional_unit = as.integer(is_el_regional_unit)
  )
  
dbWriteTable(con_sqlite, "gen_nuts", d_gen_nuts, overwrite = TRUE)

