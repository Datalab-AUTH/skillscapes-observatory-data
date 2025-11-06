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

d_eu_labour_skill_youth_skills <- dbGetQuery(con_postgres, "SELECT * FROM rslb_user.b54_isco") |>
  filter(age == "15 - 29 years") |>
  filter(isco08_1d != "Not stated") |>
  select(-period, -age) |>
  rename(
    "geo" = "nuts_id"
  ) |>
  mutate(
    year = as.integer(year),
    value = as.integer(1000 * value),
    isco08_1d = recode(isco08_1d,
     "ISCO_0_armed forces occupations" = "youth_skills_isco_0",
     "ISCO_1-3_highly skilled non-manual" = "youth_skills_isco_1_3",
     "ISCO_4-5_low skilled non-manual" = "youth_skills_isco_4_5",
     "ISCO 6-8_skilled manual" = "youth_skills_isco_6_8",
     "ISCO_9_elementary occupations" = "youth_skills_isco_9"
    ) 
  ) |>
  pivot_wider(names_from = isco08_1d, values_from = value) |>
  mutate(
    youth_skills_total = youth_skills_isco_1_3 + youth_skills_isco_4_5 + youth_skills_isco_4_5 + youth_skills_isco_9,
    youth_skills_isco_1_3_pct = 100 * youth_skills_isco_1_3 / youth_skills_total,
    youth_skills_isco_4_5_pct = 100 * youth_skills_isco_4_5 / youth_skills_total,
    youth_skills_isco_6_8_pct = 100 * youth_skills_isco_6_8 / youth_skills_total,
    youth_skills_isco_9_pct = 100 * youth_skills_isco_9 / youth_skills_total
  ) |>
 select(-youth_skills_total)
  
dbWriteTable(con_sqlite, "eu_labour_skill_youth_skills", d_eu_labour_skill_youth_skills, overwrite = TRUE)

