#!/usr/bin/R

library(tidyverse)

d_ss25 <- read_csv('data_csv/SS25.csv')
d_ss25 <- d_ss25 %>%
  arrange(NUTS, Year) %>%
  group_by(NUTS) %>% 
  mutate(
    GVA_pct = 100 * GVA / Total,
    GVA_prev = lag(GVA),
    GVA_pct_diff = ifelse(is.na(GVA_prev), NA, ((GVA - GVA_prev) / GVA_prev) * 100)
  )
d_ss25_NUTS1 <- d_ss25 %>%
  filter(str_sub(NUTS, 2, 2) %>% str_detect("[[:upper:]]")) %>%
  filter(NUTS != "ELLADA") |>
  mutate(NUTS_level = 1)
d_ss25_NUTS2 <- d_ss25 %>%
  filter(NUTS == "Attiki" | NUTS == "Voreio Aigaio" | NUTS == "Notio Aigaio" | NUTS == "Kriti" | NUTS == "Anatoliki Makedonia, Thraki" | NUTS == "Kentriki Makedonia" | NUTS == "Dytiki Makedonia" | NUTS == "Ipeiros" | NUTS == "Thessalia" | NUTS == "Ionia Nisia" | NUTS == "Dytiki Ellada" | NUTS == "Sterea Ellada" | NUTS == "Peloponnisos") |>
  mutate(NUTS_level = 2)
d_ss25_NUTS3 <- d_ss25 %>%
  filter(!(NUTS == "Attiki" | NUTS == "Voreio Aigaio" | NUTS == "Notio Aigaio" | NUTS == "Kriti" | NUTS == "Anatoliki Makedonia, Thraki" | NUTS == "Kentriki Makedonia" | NUTS == "Dytiki Makedonia" | NUTS == "Ipeiros" | NUTS == "Thessalia" | NUTS == "Ionia Nisia" | NUTS == "Dytiki Ellada" | NUTS == "Sterea Ellada" | NUTS == "Peloponnisos")) %>%
  filter(str_sub(NUTS, 2, 2) %>% str_detect("[[:lower:]]")) |>
  mutate(NUTS_level = 3)
d <- rbind(d_ss25_NUTS1, d_ss25_NUTS2, d_ss25_NUTS3) |>
  select(-GVA_prev) |>
  rename(
    "GVA_GHI" = "GVA",
    "GVA_total" = "Total",
    "GVA_GHI_pct" = "GVA_pct",
    "GVA_GHI_pct_diff" = "GVA_pct_diff",
    "year" = "Year",
    "NUTS_label" = "NUTS"
  )

write_csv(d, "data/greek_tourism_GVA.csv")

