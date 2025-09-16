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

nuts_map <- tribble(
  ~label, ~code,
  # NUTS 1
  "ATTIKI", "EL3",
  "KENTRIKI ELLADA", "EL6",
  "NISIA AIGAIOU, KRITI", "EL4",
  "VOREIA ELLADA", "EL5",
  
  # NUTS 2
  "Anatoliki Makedonia, Thraki", "EL51",
  "Attiki", "EL30",
  "Dytiki Ellada", "EL63",
  "Dytiki Makedonia", "EL53",
  "Ionia Nisia", "EL62",
  "Ipeiros", "EL54",
  "Kentriki Makedonia", "EL52",
  "Kriti", "EL43",
  "Notio Aigaio", "EL42",
  "Peloponnisos", "EL65",
  "Sterea Ellada", "EL64",
  "Thessalia", "EL61",
  "Voreio Aigaio", "EL41",
  
  # NUTS 3
  "Achaia", "EL632",
  "Aitoloakarnania", "EL631",
  "Anatoliki Attiki", "EL305",
  "Andros, Thira, Kea, Milos, Mykonos, Naxos, Paros, Syros, Tinos", "EL422",
  "Argolida", "EL651",
  "Arkadia", "EL651",
  "Arta", "EL541",
  "Chalkidiki", "EL527",
  "Chania", "EL434",
  "Chios", "EL413",
  "Drama", "EL514",
  "Dytiki Attiki", "EL306",
  "Dytikos Tomeas Athinon", "EL302",
  "Evros", "EL511",
  "Evrytania", "EL643",
  "Evvoia", "EL642",
  "Florina", "EL533",
  "Fokida", "EL645",
  "Fthiotida", "EL644",
  "Grevena", "EL531",
  "Ikaria, Samos", "EL412",
  "Ileia", "EL633",
  "Imathia", "EL521",
  "Ioannina", "EL543",
  "Irakleio", "EL431",
  "Ithaki, Kefallinia", "EL623",
  "Kalymnos, Karpathos, Kos, Rodos", "EL421",
  "Karditsa", "EL611",
  "Kastoria", "EL532",
  "Kentrikos Tomeas Athinon", "EL303",
  "Kerkyra", "EL622",
  "Kilkis", "EL523",
  "Korinthia", "EL652",
  "Kozani", "EL531",
  "Lakonia", "EL653",
  "Larisa", "EL612",
  "Lasithi", "EL432",
  "Lefkada", "EL624",
  "Lesvos, Limnos", "EL411",
  "Magnisia", "EL613",
  "Messinia", "EL653",
  "Notios Tomeas Athinon", "EL304",
  "Peiraias, Nisoi", "EL307",
  "Pella", "EL524",
  "Pieria", "EL525",
  "Preveza", "EL541",
  "Rethymni", "EL433",
  "Rodopi", "EL513",
  "Serres", "EL526",
  "Thasos, Kavala", "EL515",
  "Thesprotia", "EL542",
  "Thessaloniki", "EL522",
  "Trikala", "EL611",
  "Voiotia", "EL641",
  "Voreios Tomeas Athinon", "EL301",
  "Xanthi", "EL512",
  "Zakynthos", "EL621"
)

d_with_NUTS_codes <- d %>%
  left_join(nuts_map, by = c("NUTS_label" = "label")) %>%
  mutate(geo = code) %>%
  select(-code) |>
  relocate(geo, .before=everything()) |>
  relocate(NUTS_level, .after=NUTS_label)

write_csv(d_with_NUTS_codes, "data/greek_tourism_GVA.csv")

