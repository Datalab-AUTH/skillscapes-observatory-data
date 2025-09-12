#!/usr/bin/Rscript

library(tidyverse)
library(eurostat)
library(readxl)

d_all <- get_eurostat('nama_10r_3empers',
                  filters = list(
                    wstatus = "EMP"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -wstatus, -unit ) |>
  mutate(values = 1000 * values) |>
  rename("sector_employment" = "values") |>
  rename("year" = "time") |>
  filter(year >= 2008)

d_total <- d_all |>
  filter(nace_r2 == "TOTAL") |>
  rename("total_employment" = "sector_employment") |>
  select(-nace_r2)
d_sector <- d_all |>
  filter(nace_r2 != "TOTAL")
d_wide <- d_sector |>
  left_join(d_total, by=c("geo", "year")) |>
  mutate(sector_employment_pct = 100 * sector_employment / total_employment)

d_NUTS_codes <- read_excel("data/NUTS2021-NUTS2024.xlsx") |>
  rename(
    "geo" = "NUTS Code",
    "geo_label" = "NUTS label",
    "NUTS_level" = "NUTS level",
    "Country_code" = "Country code"
  ) |>
  select(-"Country order", -"#")
d_countries <- rbind(eu_countries, ea_countries, efta_countries, eu_candidate_countries) |>
  distinct() |>
  select(-label) |>
  rename(
    "geo_label" = "name",
    "geo" = "code"
  ) |>
  mutate (
    "NUTS_level" = 0,
    "Country_code" = geo
  )
d_regions <- rbind(d_countries, d_NUTS_codes)

d <- d_wide |>
  left_join(d_regions, by="geo") |>
  filter(!is.na(geo_label)) |>
  arrange("geo", "year", "nace_r2") |>
  group_by(geo, nace_r2) |>
  mutate(
    sector_employment_prev = lag(sector_employment),
    sector_employment_pct_diff = ifelse(is.na(sector_employment_prev), NA, ((sector_employment - sector_employment_prev) / sector_employment_prev) * 100
    )) |>
  select(-sector_employment_prev) |>
  relocate(geo_label, .after=geo) |>
  relocate(NUTS_level, .after=geo_label) |>
  relocate(Country_code, .after=NUTS_level) |>
  ungroup()

write_csv(d, "data/EULaborMarket-SectoralEmployment.csv")
