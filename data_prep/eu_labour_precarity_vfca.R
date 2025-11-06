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

d_eu_labour_precarity_vfca <- dbGetQuery(con_postgres, "SELECT * FROM rslb_user.b53_vfca") |>
  rename(
    "geo" = "nuts_id"
  ) |>
  mutate(
    year = as.integer(year)
  )
  
dbWriteTable(con_sqlite, "eu_labour_precarity_vfca", d_eu_labour_precarity_vfca, overwrite = TRUE)

