#!/usr/bin/Rscript

library(tidyverse)

d_ss23 <- read_csv('data_csv/SS23.csv')

d_ss23_NUTS2 <- d_ss23 |>
  select(-NUTS3) |>
  arrange(NUTS2, Year) |>
  group_by(NUTS2, Year) |>
  summarize(Turnover_Catering = sum(Turnover_Catering, na.rm = TRUE),
            Turnover_Accomodation = sum(Turnover_Accomodation, na.rm = TRUE)) |>
  ungroup() |>
  rename("NUTS_label" = "NUTS2") |>
  mutate(NUTS_level = 2)

d_ss23_NUTS3 <- d_ss23 |>
  select(-NUTS2) |>
  arrange(NUTS3, Year) |>
  rename("NUTS_label" = "NUTS3") |>
  mutate(NUTS_level = 3)

d_ss23_NUTS1 <- d_ss23 |>
  select(-NUTS3) |>
  mutate(
    NUTS1 = case_when(
      NUTS2 == "ΑΝΑΤΟΛΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ ΚΑΙ ΘΡΑΚΗΣ" ~ "Βόρεια Ελλάδα",
      NUTS2 == "ΑΤΤΙΚΗΣ" ~ "Αττική",
      NUTS2 == "ΒΟΡΕΙΟΥ ΑΙΓΑΙΟΥ" ~ "Νησιά Αιγαίου, Κρήτη",
      NUTS2 == "ΔΥΤΙΚΗΣ ΕΛΛΑΔΑΣ" ~ "Κεντρική Ελλάδα",
      NUTS2 == "ΔΥΤΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ" ~ "Βόρεια Ελλάδα",
      NUTS2 == "ΗΠΕΙΡΟΥ" ~ "Βόρεια Ελλάδα",
      NUTS2 == "ΘΕΣΣΑΛΙΑΣ" ~ "Κεντρική Ελλάδα",
      NUTS2 == "ΙΟΝΙΩΝ ΝΗΣΩΝ" ~ "Κεντρική Ελλάδα",
      NUTS2 == "ΚΕΝΤΡΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ" ~ "Βόρεια Ελλάδα",
      NUTS2 == "ΚΡΗΤΗΣ" ~ "Νησιά Αιγαίου, Κρήτη",
      NUTS2 == "ΝΟΤΙΟΥ ΑΙΓΑΙΟΥ" ~ "Νησιά Αιγαίου, Κρήτη",
      NUTS2 == "ΠΕΛΟΠΟΝΝΗΣΟΥ" ~ "Κεντρική Ελλάδα",
      NUTS2 == "ΣΤΕΡΕΑΣ ΕΛΛΑΔΑΣ" ~ "Κεντρική Ελλάδα"
    )
  ) |>
  arrange(NUTS1, Year) |>
  group_by(NUTS1, Year) |>
  summarize(Turnover_Catering = sum(Turnover_Catering, na.rm = TRUE),
            Turnover_Accomodation = sum(Turnover_Accomodation, na.rm = TRUE)) |>
  ungroup() |>
  rename("NUTS_label" = "NUTS1") |>
  mutate(NUTS_level = 1)

d <- rbind(d_ss23_NUTS1, d_ss23_NUTS2, d_ss23_NUTS3) |>
  rename("year" = "Year") |>
  arrange(NUTS_level, NUTS_label, year) |>
  group_by(NUTS_level, NUTS_label) |>
  mutate(
    Turnover_Catering_prev = lag(Turnover_Catering),
    Turnover_Accomodation_prev = lag(Turnover_Accomodation),
    Turnover_Catering_pct_diff = ifelse(is.na(Turnover_Catering_prev), NA, ((Turnover_Catering - Turnover_Catering_prev) / Turnover_Catering_prev) * 100),
    Turnover_Accomodation_pct_diff = ifelse(is.na(Turnover_Accomodation_prev), NA, ((Turnover_Accomodation - Turnover_Accomodation_prev) / Turnover_Accomodation_prev) * 100)
  ) |>
  ungroup() |>
  select(-Turnover_Catering_prev, -Turnover_Accomodation_prev) |>
  relocate(NUTS_level, .before=year)

write_csv(d, "data/greek_tourism_Turnover.csv")
