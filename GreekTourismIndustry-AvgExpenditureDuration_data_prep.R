#!/usr/bin/Rscript

library(tidyverse)

d_Attica <- read_csv('data_csv/SS33-Attica.csv')
d_Central_Greece <- read_csv('data_csv/SS33-Central_Greece.csv')
d_Central_Macedonia <- read_csv('data_csv/SS33-Central_Macedonia.csv')
d_Crete <- read_csv('data_csv/SS33-Crete.csv')
d_Eastern_Macedonia_Thrace <- read_csv('data_csv/SS33-Eastern_Macedonia-Thrace.csv')
d_Epirus <- read_csv('data_csv/SS33-Epirus.csv')
d_Ionian_Islands <- read_csv('data_csv/SS33-Ionian_Islands.csv')
d_North_Aegean <- read_csv('data_csv/SS33-North_Aegean.csv')
d_Peloponnese <- read_csv('data_csv/SS33-Peloponnese.csv')
d_South_Aegean <- read_csv('data_csv/SS33-South_Aegean.csv')
d_Thessaly <- read_csv('data_csv/SS33-Thessaly.csv')
d_Western_Greece <- read_csv('data_csv/SS33-Western_Greece.csv')
d_Western_Macedonia <- read_csv('data_csv/SS33-Western_Macedonia.csv')

nuts2_dict <- c(
  "Attica" = "EL30",
  "Central Greece" = "EL64",
  "Central Macedonia" = "EL52",
  "Crete" = "EL43",
  "Eastern Macedonia & Thrace" = "EL51",
  "Epirus" = "EL54",
  "Ionian Islands" = "EL62",
  "North Aegean" = "EL41",
  "Peloponnese" = "EL65",
  "South Aegean" = "EL42",
  "Thessaly" = "EL61",
  "Western Greece" = "EL63",
  "Western Macedonia" = "EL53"
)

d <- bind_rows(
  d_Attica,
  d_Central_Greece,
  d_Central_Macedonia,
  d_Crete,
  d_Eastern_Macedonia_Thrace,
  d_Epirus,
  d_Ionian_Islands,
  d_North_Aegean,
  d_Peloponnese,
  d_South_Aegean,
  d_Thessaly,
  d_Western_Greece,
  d_Western_Macedonia
) |>
  arrange(Region, Year) |>
  group_by(Region) |>
  mutate(
    Avg_expenditure_per_journey_prev = lag(Avg_expenditure_per_journey),
    Avg_expenditure_per_stay_prev = lag(Avg_expenditure_per_stay),
    Avg_duration_of_stay_prev = lag(Avg_duration_of_stay),
    Avg_expenditure_per_journey_pct_diff = ifelse(is.na(Avg_expenditure_per_journey_prev), NA, ((Avg_expenditure_per_journey - Avg_expenditure_per_journey_prev) / Avg_expenditure_per_journey_prev) * 100),
    Avg_expenditure_per_stay_pct_diff = ifelse(is.na(Avg_expenditure_per_stay_prev), NA, ((Avg_expenditure_per_stay - Avg_expenditure_per_stay_prev) / Avg_expenditure_per_stay_prev) * 100),
    Avg_expenditure_per_stay_pct_diff = ifelse(is.na(Avg_expenditure_per_stay_prev), NA, ((Avg_expenditure_per_stay - Avg_expenditure_per_stay_prev) / Avg_expenditure_per_stay_prev) * 100),
    Avg_duration_of_stay_pct_diff = ifelse(is.na(Avg_duration_of_stay_prev), NA, ((Avg_duration_of_stay - Avg_duration_of_stay_prev) / Avg_duration_of_stay_prev) * 100)
  ) |>
  ungroup() |>
  relocate(Year, .before=everything()) |>
  relocate(Region, .before=everything()) |>
  select(-ends_with("_prev"))
write_csv(d, "data/greek_tourism_AvgExpenditureDuration.csv")
