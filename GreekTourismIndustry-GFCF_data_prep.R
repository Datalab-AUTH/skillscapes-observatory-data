#!/usr/bin/Rscript

library(tidyverse)

nuts1_dict <- c(
  "ATTIKI" = "EL3",
  "VOREIA ELLADA" = "EL5",
  "KENTRIKI ELLADA" = "EL6",
  "NISIA AIGAIOU, KRITI" = "EL4"
)

nuts2_dict <- c(
  "Anatoliki Makedonia, Thraki" = "EL51",
  "Attiki" = "EL30",
  "Voreio Aigaio" = "EL41",
  "Dytiki Ellada" = "EL63",
  "Dytiki Makedonia" = "EL53",
  "Ipeiros" = "EL54",
  "Thessalia" = "EL61",
  "Ionia Nisia" = "EL62",
  "Kentriki Makedonia" = "EL52",
  "Kriti" = "EL43",
  "Notio Aigaio" = "EL42",
  "Peloponnisos" = "EL65",
  "Sterea Ellada" = "EL64"
)


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
  ungroup() |>
  filter(NUTS != "ELLADA")
d_ss24_NUTS1 <- d_ss24 |>
  filter(str_sub(NUTS, 2, 2) |> str_detect("[[:upper:]]")) |>
  mutate("NUTS_level" = 1) |>
  mutate(geo = recode(NUTS, !!!nuts1_dict))

d_ss24_NUTS2 <- d_ss24 |>
  filter(str_sub(NUTS, 2, 2) |> str_detect("[[:lower:]]")) |>
  mutate("NUTS_level" = 2) |>
  mutate(geo = recode(NUTS, !!!nuts2_dict))

d <- rbind(d_ss24_NUTS1, d_ss24_NUTS2) |>
  relocate(NUTS_level, .after=NUTS_el) |>
  relocate(Year, .after=NUTS_level) |>
  rename("year" = "Year") |>
  relocate(geo, .before=everything()) |>
  rename(
    "NUTS_label" = "NUTS",
    "NUTS_label_el" = "NUTS_el"
  )

write_csv(d, "data/greek_tourism_GFCF.csv")
