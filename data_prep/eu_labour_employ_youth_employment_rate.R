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

d_eu_labour_youth_employment_rate <- dbGetQuery(con_postgres, "SELECT * FROM rslb_user.b63_neets_full") |>
  filter(sex == "T") |>
  rename(
    "geo" = "nuts_id",
    "youth_employment_rate" = "employment_pop_prc"
  ) |>
  select(geo, year, youth_employment_rate) |>
  mutate(
    year = as.integer(year)
  )

dbWriteTable(con_sqlite, "eu_labour_youth_employment_rate", d_eu_labour_youth_employment_rate, overwrite = TRUE)

