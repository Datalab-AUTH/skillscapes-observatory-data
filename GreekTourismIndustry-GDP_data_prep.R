#!/usr/bin/R

library(eurostat)

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
    ) |>
  mutate(
    NUTS_level = case_when(
      str_length(geo) == 2 ~ 0,
      str_length(geo) == 3 ~ 1,
      str_length(geo) == 4 ~ 2
    )
  ) |>
  relocate(NUTS_level, .after=geo)
write_csv(d, "data/greek_tourism_GDP.csv")

