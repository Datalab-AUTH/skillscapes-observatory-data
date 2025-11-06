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

d_eu_labour_precarity_neets <- dbGetQuery(con_postgres, "SELECT * FROM rslb_user.b63_neets_full") |>
  filter(sex == "T") |>
  filter(year >= 2008) |>
  select(nuts_id, year, neets, neets_pop_prc) |>
  rename(
    "geo" = "nuts_id"
  ) |>
  mutate(
    year = as.integer(year),
    neets = as.integer(1000 * neets),
  )
  
dbWriteTable(con_sqlite, "eu_labour_precarity_neets", d_eu_labour_precarity_neets, overwrite = TRUE)

