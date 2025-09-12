#!/usr/bin/Rscript

library(tidyverse)

d_SS28_2024 <- read_csv("data_csv/SS28-2024.csv") |>
  mutate(Year = 2024)
d_SS28_2023 <- read_csv("data_csv/SS28-2023.csv") |>
  mutate(Year = 2023)
d_SS28_2022 <- read_csv("data_csv/SS28-2022.csv") |>
  mutate(Year = 2022)
d_SS28_2021 <- read_csv("data_csv/SS28-2021.csv") |>
  mutate(Year = 2021)
d_SS28_2020 <- read_csv("data_csv/SS28-2020.csv") |>
  mutate(Year = 2020)
d_SS28_2019 <- read_csv("data_csv/SS28-2019.csv") |>
  mutate(Year = 2019)
d_SS28_2018 <- read_csv("data_csv/SS28-2018.csv") |>
  mutate(Year = 2018)
d_SS28_2017 <- read_csv("data_csv/SS28-2017.csv") |>
  mutate(Year = 2017)
d_SS28_2016 <- read_csv("data_csv/SS28-2016.csv") |>
  mutate(Year = 2016)
d_SS28_2015 <- read_csv("data_csv/SS28-2015.csv") |>
  mutate(Year = 2015)
d_SS28 <- bind_rows(d_SS28_2024,
                    d_SS28_2023,
                    d_SS28_2022,
                    d_SS28_2021,
                    d_SS28_2020,
                    d_SS28_2019,
                    d_SS28_2018,
                    d_SS28_2017,
                    d_SS28_2016,
                    d_SS28_2015)
d_SS28_NUTS2 <- d_SS28 |>
  filter(NUTS3 == "ΣΥΝΟΛΟ") |>
  select(-NUTS3) |>
  arrange(NUTS2, Year) |>
  group_by(NUTS2) |>
  mutate(
    Hotel_Stays_Natives_prev = lag(Hotel_Stays_Natives),
    Hotel_Stays_Foreign_prev = lag(Hotel_Stays_Foreign),
    Hotel_Stays_Total_prev = lag(Hotel_Stays_Total),
    Hotel_Occupancy_prev = lag(Hotel_Occupancy),
    Hotel_Stays_Natives_pct_diff = ifelse(is.na(Hotel_Stays_Natives_prev), NA, ((Hotel_Stays_Natives - Hotel_Stays_Natives_prev) / Hotel_Stays_Natives_prev) * 100),
    Hotel_Stays_Foreign_pct_diff = ifelse(is.na(Hotel_Stays_Foreign_prev), NA, ((Hotel_Stays_Foreign - Hotel_Stays_Foreign_prev) / Hotel_Stays_Foreign_prev) * 100),
    Hotel_Stays_Total_pct_diff = ifelse(is.na(Hotel_Stays_Total_prev), NA, ((Hotel_Stays_Total - Hotel_Stays_Total_prev) / Hotel_Stays_Total_prev) * 100),
    Hotel_Occupancy_pct_diff = ifelse(is.na(Hotel_Occupancy_prev), NA, ((Hotel_Occupancy - Hotel_Occupancy_prev) / Hotel_Occupancy_prev) * 100)
  ) |>
  mutate(NUTS_level = 2) |>
  ungroup() |>
  rename("NUTS_label" = "NUTS2")
d_SS28_NUTS3 <- d_SS28 |>
  filter(NUTS3 != "ΣΥΝΟΛΟ") |>
  select(-NUTS2) |>
  arrange(NUTS3, Year) |>
  group_by(NUTS3) |>
  mutate(
    Hotel_Stays_Natives_prev = lag(Hotel_Stays_Natives),
    Hotel_Stays_Foreign_prev = lag(Hotel_Stays_Foreign),
    Hotel_Stays_Total_prev = lag(Hotel_Stays_Total),
    Hotel_Occupancy_prev = lag(Hotel_Occupancy),
    Hotel_Stays_Natives_pct_diff = ifelse(is.na(Hotel_Stays_Natives_prev), NA, ((Hotel_Stays_Natives - Hotel_Stays_Natives_prev) / Hotel_Stays_Natives_prev) * 100),
    Hotel_Stays_Foreign_pct_diff = ifelse(is.na(Hotel_Stays_Foreign_prev), NA, ((Hotel_Stays_Foreign - Hotel_Stays_Foreign_prev) / Hotel_Stays_Foreign_prev) * 100),
    Hotel_Stays_Total_pct_diff = ifelse(is.na(Hotel_Stays_Total_prev), NA, ((Hotel_Stays_Total - Hotel_Stays_Total_prev) / Hotel_Stays_Total_prev) * 100),
    Hotel_Occupancy_pct_diff = ifelse(is.na(Hotel_Occupancy_prev), NA, ((Hotel_Occupancy - Hotel_Occupancy_prev) / Hotel_Occupancy_prev) * 100)
  ) |>
  mutate(NUTS_level = 3) |>
  ungroup() |>
  rename("NUTS_label" = "NUTS3")

d <- rbind(d_SS28_NUTS2, d_SS28_NUTS3) |>
  relocate(Year, .after=NUTS_label) |>
  relocate(NUTS_level, .after=Year) |>
  select(-ends_with("_prev")) |>
  rename("year" = "Year")

write_csv(d, "data/greek_tourism_Stays.csv")