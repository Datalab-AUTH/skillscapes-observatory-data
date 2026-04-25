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
    sector_a = 1000 * sector_a,
    sector_bde = 1000 * sector_bde,
    sector_c = 1000 * sector_c,
    sector_f = 1000 * sector_f,
    sector_g = 1000 * sector_g,
    sector_h = 1000 * sector_h,
    sector_i = 1000 * sector_i,
    sector_jklmnu = 1000 * sector_jklmnu,
    sector_opq = 1000 * sector_opq,
    sector_rst = 1000 * sector_rst
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
  group_by(geo) |>
  mutate(
    sector_a_prev_year = lag(sector_a),
    sector_bde_prev_year = lag(sector_bde),
    sector_c_prev_year = lag(sector_c),
    sector_f_prev_year = lag(sector_f),
    sector_g_prev_year = lag(sector_g),
    sector_h_prev_year = lag(sector_h),
    sector_i_prev_year = lag(sector_i),
    sector_jklmnu_prev_year = lag(sector_jklmnu),
    sector_opq_prev_year = lag(sector_opq),
    sector_rst_prev_year = lag(sector_rst),
    sector_a_country_prev_year = lag(sector_a_country),
    sector_bde_country_prev_year = lag(sector_bde_country),
    sector_c_country_prev_year = lag(sector_c_country),
    sector_f_country_prev_year = lag(sector_f_country),
    sector_g_country_prev_year = lag(sector_g_country),
    sector_h_country_prev_year = lag(sector_h_country),
    sector_i_country_prev_year = lag(sector_i_country),
    sector_jklmnu_country_prev_year = lag(sector_jklmnu_country),
    sector_opq_country_prev_year = lag(sector_opq_country),
    sector_rst_country_prev_year = lag(sector_rst_country),
    total_employment_prev_year = lag(total_employment),
    total_employment_country_prev_year = lag(total_employment_country),
    NS_sector_a = sector_a_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_bde = sector_bde_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_c = sector_c_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_f = sector_f_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_g = sector_g_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_h = sector_h_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_i = sector_i_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_jklmnu = sector_jklmnu_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_opq = sector_opq_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    NS_sector_rst = sector_rst_prev_year * (total_employment - total_employment_prev_year) / total_employment_prev_year,
    IM_sector_a = sector_a_prev_year * ((sector_a_country - sector_a_country_prev_year) / sector_a_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_bde = sector_bde_prev_year * ((sector_bde_country - sector_bde_country_prev_year) / sector_bde_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_c = sector_c_prev_year * ((sector_c_country - sector_c_country_prev_year) / sector_c_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_f = sector_f_prev_year * ((sector_f_country - sector_f_country_prev_year) / sector_f_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_g = sector_g_prev_year * ((sector_g_country - sector_g_country_prev_year) / sector_g_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_h = sector_h_prev_year * ((sector_h_country - sector_h_country_prev_year) / sector_h_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_i = sector_i_prev_year * ((sector_i_country - sector_i_country_prev_year) / sector_i_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_jklmnu = sector_jklmnu_prev_year * ((sector_jklmnu_country - sector_jklmnu_country_prev_year) / sector_jklmnu_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_opq = sector_opq_prev_year * ((sector_opq_country - sector_opq_country_prev_year) / sector_opq_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    IM_sector_rst = sector_rst_prev_year * ((sector_rst_country - sector_rst_country_prev_year) / sector_rst_country_prev_year - (total_employment - total_employment_prev_year) / total_employment_prev_year),
    RS_sector_a = sector_a_prev_year * ((sector_a - sector_a_prev_year) / sector_a_prev_year - (sector_a_country - sector_a_country_prev_year) / sector_a_country_prev_year),
    RS_sector_bde = sector_bde_prev_year * ((sector_bde - sector_bde_prev_year) / sector_bde_prev_year - (sector_bde_country - sector_bde_country_prev_year) / sector_bde_country_prev_year),
    RS_sector_c = sector_c_prev_year * ((sector_c - sector_c_prev_year) / sector_c_prev_year - (sector_c_country - sector_c_country_prev_year) / sector_c_country_prev_year),
    RS_sector_f = sector_f_prev_year * ((sector_f - sector_f_prev_year) / sector_f_prev_year - (sector_f_country - sector_f_country_prev_year) / sector_f_country_prev_year),
    RS_sector_g = sector_g_prev_year * ((sector_g - sector_g_prev_year) / sector_g_prev_year - (sector_g_country - sector_g_country_prev_year) / sector_g_country_prev_year),
    RS_sector_h = sector_h_prev_year * ((sector_h - sector_h_prev_year) / sector_h_prev_year - (sector_h_country - sector_h_country_prev_year) / sector_h_country_prev_year),
    RS_sector_i = sector_i_prev_year * ((sector_i - sector_i_prev_year) / sector_i_prev_year - (sector_i_country - sector_i_country_prev_year) / sector_i_country_prev_year),
    RS_sector_jklmnu = sector_jklmnu_prev_year * ((sector_jklmnu - sector_jklmnu_prev_year) / sector_jklmnu_prev_year - (sector_jklmnu_country - sector_jklmnu_country_prev_year) / sector_jklmnu_country_prev_year),
    RS_sector_opq = sector_opq_prev_year * ((sector_opq - sector_opq_prev_year) / sector_opq_prev_year - (sector_opq_country - sector_opq_country_prev_year) / sector_opq_country_prev_year),
    RS_sector_rst = sector_rst_prev_year * ((sector_rst - sector_rst_prev_year) / sector_rst_prev_year - (sector_rst_country - sector_rst_country_prev_year) / sector_rst_country_prev_year),
    NS_pct_sector_a = 100 * NS_sector_a / sector_a_prev_year,
    NS_pct_sector_bde = 100 * NS_sector_bde / sector_bde_prev_year,
    NS_pct_sector_c = 100 * NS_sector_c / sector_c_prev_year,
    NS_pct_sector_f = 100 * NS_sector_f / sector_f_prev_year,
    NS_pct_sector_g = 100 * NS_sector_g / sector_g_prev_year,
    NS_pct_sector_h = 100 * NS_sector_h / sector_h_prev_year,
    NS_pct_sector_i = 100 * NS_sector_i / sector_i_prev_year,
    NS_pct_sector_jklmnu = 100 * NS_sector_jklmnu / sector_jklmnu_prev_year,
    NS_pct_sector_opq = 100 * NS_sector_opq / sector_opq_prev_year,
    NS_pct_sector_rst = 100 * NS_sector_rst / sector_rst_prev_year,
    IM_pct_sector_a = 100 * IM_sector_a / sector_a_prev_year,
    IM_pct_sector_bde = 100 * IM_sector_bde / sector_bde_prev_year,
    IM_pct_sector_c = 100 * IM_sector_c / sector_c_prev_year,
    IM_pct_sector_f = 100 * IM_sector_f / sector_f_prev_year,
    IM_pct_sector_g = 100 * IM_sector_g / sector_g_prev_year,
    IM_pct_sector_h = 100 * IM_sector_h / sector_h_prev_year,
    IM_pct_sector_i = 100 * IM_sector_i / sector_i_prev_year,
    IM_pct_sector_jklmnu = 100 * IM_sector_jklmnu / sector_jklmnu_prev_year,
    IM_pct_sector_opq = 100 * IM_sector_opq / sector_opq_prev_year,
    IM_pct_sector_rst = 100 * IM_sector_rst / sector_rst_prev_year,
    NS_pct_sector_a = 100 * NS_sector_a / sector_a_prev_year,
    NS_pct_sector_bde = 100 * NS_sector_bde / sector_bde_prev_year,
    NS_pct_sector_c = 100 * NS_sector_c / sector_c_prev_year,
    NS_pct_sector_f = 100 * NS_sector_f / sector_f_prev_year,
    NS_pct_sector_g = 100 * NS_sector_g / sector_g_prev_year,
    NS_pct_sector_h = 100 * NS_sector_h / sector_h_prev_year,
    NS_pct_sector_i = 100 * NS_sector_i / sector_i_prev_year,
    NS_pct_sector_jklmnu = 100 * NS_sector_jklmnu / sector_jklmnu_prev_year,
    NS_pct_sector_opq = 100 * NS_sector_opq / sector_opq_prev_year,
    NS_pct_sector_rst = 100 * NS_sector_rst / sector_rst_prev_year,
    RS_pct_sector_a = 100 * RS_sector_a / sector_a_prev_year,
    RS_pct_sector_bde = 100 * RS_sector_bde / sector_bde_prev_year,
    RS_pct_sector_c = 100 * RS_sector_c / sector_c_prev_year,
    RS_pct_sector_f = 100 * RS_sector_f / sector_f_prev_year,
    RS_pct_sector_g = 100 * RS_sector_g / sector_g_prev_year,
    RS_pct_sector_h = 100 * RS_sector_h / sector_h_prev_year,
    RS_pct_sector_i = 100 * RS_sector_i / sector_i_prev_year,
    RS_pct_sector_jklmnu = 100 * RS_sector_jklmnu / sector_jklmnu_prev_year,
    RS_pct_sector_opq = 100 * RS_sector_opq / sector_opq_prev_year,
    RS_pct_sector_rst = 100 * RS_sector_rst / sector_rst_prev_year,
    NS_region = NS_sector_a + NS_sector_bde + NS_sector_c + NS_sector_f + NS_sector_g + NS_sector_f + NS_sector_g + NS_sector_h + NS_sector_i + NS_sector_jklmnu + NS_sector_opq + NS_sector_rst,
    IM_region = IM_sector_a + IM_sector_bde + IM_sector_c + IM_sector_f + IM_sector_g + IM_sector_f + IM_sector_g + IM_sector_h + IM_sector_i + IM_sector_jklmnu + IM_sector_opq + IM_sector_rst,
    RS_region = RS_sector_a + RS_sector_bde + RS_sector_c + RS_sector_f + RS_sector_g + RS_sector_f + RS_sector_g + RS_sector_h + RS_sector_i + RS_sector_jklmnu + RS_sector_opq + RS_sector_rst,
    NS_pct_region = 100 * NS_region / total_employment_prev_year,
    IM_pct_region = 100 * IM_region / total_employment_prev_year,
    RS_pct_region = 100 * RS_region / total_employment_prev_year,
    SSA_actual_change = NS_pct_region + IM_pct_region + RS_pct_region
  ) |>
  select(-total_employment, -country_code, -ends_with('country'), -ends_with('_prev_year'))

dbWriteTable(con_sqlite, "eu_labour_sector_employment", d_eu_labour_sector_employment, overwrite = TRUE)
