#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)
library(RPostgres)
library(dotenv)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

if (!exists('con_postgres')) {
  load_dot_env("env")
  con_postgres <- dbConnect(
    Postgres(),
    host = Sys.getenv("PGHOST"),
    port = Sys.getenv("PGPORT"),
    dbname = Sys.getenv("PGDATABASE"),
    user = Sys.getenv("PGUSER"),
    password = Sys.getenv("PGPASSWORD")
  )
}

if (!exists('d_eu_labour_total_employment')) {
  source('eu_labour_employ_total_employment.R')
}
if (!exists('d_gen_nuts')) {
  source('gen_nuts.R')
}

d_country_total_employment <- d_eu_labour_total_employment |>
  left_join(d_gen_nuts, by="geo") |>
  filter(nuts_level == 0) |>
  rename(total_employment_country = total_employment) |>
  mutate(country_code = geo) |>
  select(country_code, year, total_employment_country)
  
d_eu_labour_sector_employment <- dbGetQuery(con_postgres, "SELECT * FROM rslb_user.b41_empl_data_abs") |>
  filter(period == "A") |>
  select(-period, -neets, -employment, -unemployment, -inactive) |>
  rename(
    "geo" = "nuts_id"
  ) |>
  mutate(
    year = as.integer(year),
    sector_a = as.integer(1000 * sector_a),
    sector_bde = as.integer(1000 * sector_bde),
    sector_c = as.integer(1000 * sector_c),
    sector_f = as.integer(1000 * sector_f),
    sector_g = as.integer(1000 * sector_g),
    sector_h = as.integer(1000 * sector_h),
    sector_i = as.integer(1000 * sector_i),
    sector_jklmnu = as.integer(1000 * sector_jklmnu),
    sector_opq = as.integer(1000 * sector_opq),
    sector_rst = as.integer(1000 * sector_rst)
  ) |>
  left_join(d_eu_labour_total_employment, by=c("geo", "year")) |>
  mutate(
    sector_a_pct = 100 * sector_a / total_employment,
    sector_bde_pct = 100 * sector_bde / total_employment,
    sector_c_pct = 100 * sector_c / total_employment,
    sector_f_pct = 100 * sector_f / total_employment,
    sector_g_pct = 100 * sector_g / total_employment,
    sector_h_pct = 100 * sector_h / total_employment,
    sector_i_pct = 100 * sector_i / total_employment,
    sector_jklmnu_pct = 100 * sector_jklmnu / total_employment,
    sector_opq_pct = 100 * sector_opq / total_employment,
    sector_rst_pct = 100 * sector_rst / total_employment
  ) |>
  mutate(country_code = str_sub(geo, 1, 2))

d_country_sector_employment <- d_eu_labour_sector_employment |>
  left_join(d_gen_nuts, by="geo") |>
  filter(nuts_level == 0) |>
  rename(
    country_code = geo,
    sector_a_country = sector_a,
    sector_bde_country = sector_bde,
    sector_c_country = sector_c,
    sector_f_country = sector_f,
    sector_g_country = sector_g,
    sector_h_country = sector_h,
    sector_i_country = sector_i,
    sector_jklmnu_country = sector_jklmnu,
    sector_opq_country = sector_opq,
    sector_rst_country = sector_rst
  ) |>
  select(country_code, year, ends_with("_country"))

d_eu_labour_sector_employment <- d_eu_labour_sector_employment |>
  left_join(d_country_total_employment, by=c("country_code", "year")) |>
  left_join(d_country_sector_employment, by=c("country_code", "year")) |>
  mutate(
    sector_a_lq = (sector_a / total_employment) / (sector_a_country / total_employment_country),
    sector_bde_lq = (sector_bde / total_employment) / (sector_bde_country / total_employment_country),
    sector_c_lq = (sector_c / total_employment) / (sector_c_country / total_employment_country),
    sector_f_lq = (sector_f / total_employment) / (sector_f_country / total_employment_country),
    sector_g_lq = (sector_g / total_employment) / (sector_g_country / total_employment_country),
    sector_h_lq = (sector_h / total_employment) / (sector_h_country / total_employment_country),
    sector_i_lq = (sector_i / total_employment) / (sector_i_country / total_employment_country),
    sector_jklmnu_lq = (sector_jklmnu / total_employment) / (sector_jklmnu_country / total_employment_country),
    sector_opq_lq = (sector_opq / total_employment) / (sector_opq_country / total_employment_country),
    sector_rst_lq = (sector_rst / total_employment) / (sector_rst_country / total_employment_country)
  ) |>
  select(-total_employment, -country_code, -ends_with('country'))

dbWriteTable(con_sqlite, "eu_labour_sector_employment", d_eu_labour_sector_employment, overwrite = TRUE)
