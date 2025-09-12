#!/usr/bin/Rscript

library(tidyverse)

d_ss24 <- read_csv("data_csv/SS24.csv")
d_ss24 <- d_ss24 |>
  arrange(NUTS, Year) |>
  group_by(NUTS) |> 
  mutate(
    GFCF_pct = 100 * GFCF_GHI / GFCF_Total,
    GFCF_GHI_prev = lag(GFCF_GHI),
    GFCF_pct_diff = ifelse(is.na(GFCF_GHI_prev), NA, ((GFCF_GHI - GFCF_GHI_prev) / GFCF_GHI_prev) * 100)
  ) |>
  select(-GFCF_GHI_prev) |>
  ungroup()
d_ss24_NUTS1 <- d_ss24 |>
  filter(str_sub(NUTS, 2, 2) |> str_detect("[[:upper:]]")) |>
  mutate("NUTS_level" = 1)
d_ss24_NUTS2 <- d_ss24 |>
  filter(str_sub(NUTS, 2, 2) |> str_detect("[[:lower:]]")) |>
  mutate("NUTS_level" = 2)

d <- rbind(d_ss24_NUTS1, d_ss24_NUTS2) |>
  relocate(NUTS_level, .after=NUTS_el) |>
  relocate(Year, .after=NUTS_level) |>
  rename("year" = "Year")

write_csv(d, "data/greek_tourism_GFCF.csv")
