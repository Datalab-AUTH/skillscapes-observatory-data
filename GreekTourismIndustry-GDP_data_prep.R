#!/usr/bin/R

d <- get_eurostat('nama_10r_2gvagr',
                  filters = list(
                    na_item = "B1GQ"
                  ),
                  time_format = "num", stringsAsFactors = TRUE) |>
  select(-freq, -na_item) |>
  rename("year" = "time") |>
  filter(year >= 2008) |>
  spread(unit, values) |>
  rename(
    "GDP" = "I15",
    "GDP_pct_diff" = "PCH_PRE"
    )
write_csv(d, "data/greek_tourism_GDP.csv")

