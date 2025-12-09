#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

d_involuntary_part_time_employment <- read_csv("involuntary_employment/NUTS2_Involuntary_Part_Time_Employment.csv")
d_involuntary_temporary_employment <- read_csv("involuntary_employment/NUTS2_Involuntary_Temporary_Employment.csv")

d_involuntary_employment <- d_involuntary_part_time_employment |>
  full_join(d_involuntary_temporary_employment, by=c("geo", "year")) |>
  mutate(year = as.integer(year))

dbWriteTable(con_sqlite, "eu_labour_precarity_involuntary_employment", d_involuntary_employment, overwrite = TRUE)
