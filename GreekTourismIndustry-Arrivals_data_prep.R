#!/usr/bin/Rscript

library(tidyverse)

d_ss27_2023 <- read_csv("data_csv/SS27-2023.csv") |>
  mutate(Year = 2023)
d_ss27_2022 <- read_csv("data_csv/SS27-2022.csv") |>
  mutate(Year = 2022)
d_ss27_2021 <- read_csv("data_csv/SS27-2021.csv") |>
  mutate(Year = 2021)
d_ss27_2020 <- read_csv("data_csv/SS27-2020.csv") |>
  mutate(Year = 2020)
d_ss27_2019 <- read_csv("data_csv/SS27-2019.csv") |>
  mutate(Year = 2019)
d_ss27_2018 <- read_csv("data_csv/SS27-2018.csv") |>
  mutate(Year = 2018)
d_ss27_2017 <- read_csv("data_csv/SS27-2017.csv") |>
  mutate(Year = 2017)
d_ss27_2016 <- read_csv("data_csv/SS27-2016.csv") |>
  mutate(Year = 2016)
d_ss27_2015 <- read_csv("data_csv/SS27-2015.csv") |>
  mutate(Year = 2015)
d_ss27 <- bind_rows(d_ss27_2023,
                    d_ss27_2022,
                    d_ss27_2021,
                    d_ss27_2020,
                    d_ss27_2019,
                    d_ss27_2018,
                    d_ss27_2017,
                    d_ss27_2016,
                    d_ss27_2015)
d_ss27_NUTS2 <- d_ss27 |>
  filter(NUTS3 == "ΣΥΝΟΛΟ") |>
  select(-NUTS3) |>
  arrange(NUTS2, Year) |>
  group_by(NUTS2) |>
  mutate(
    Hotel_Arrivals_Natives_prev = lag(Hotel_Arrivals_Natives),
    Hotel_Arrivals_Foreign_prev = lag(Hotel_Arrivals_Foreign),
    Hotel_Arrivals_Total_prev = lag(Hotel_Arrivals_Total),
    Hotel_Beds_prev = lag(Hotel_Beds),
    Hotel_Arrivals_Natives_pct_diff = ifelse(is.na(Hotel_Arrivals_Natives_prev), NA, ((Hotel_Arrivals_Natives - Hotel_Arrivals_Natives_prev) / Hotel_Arrivals_Natives_prev) * 100),
    Hotel_Arrivals_Foreign_pct_diff = ifelse(is.na(Hotel_Arrivals_Foreign_prev), NA, ((Hotel_Arrivals_Foreign - Hotel_Arrivals_Foreign_prev) / Hotel_Arrivals_Foreign_prev) * 100),
    Hotel_Arrivals_Total_pct_diff = ifelse(is.na(Hotel_Arrivals_Total_prev), NA, ((Hotel_Arrivals_Total - Hotel_Arrivals_Total_prev) / Hotel_Arrivals_Total_prev) * 100),
    Hotel_Beds_pct_diff = ifelse(is.na(Hotel_Beds_prev), NA, ((Hotel_Beds - Hotel_Beds_prev) / Hotel_Beds_prev) * 100)
  ) |>
  ungroup() |>
  select(-ends_with("_prev")) |>
  rename("NUTS_name" = "NUTS2") |>
  mutate(NUTS_level = 2)
d_ss27_NUTS3 <- d_ss27 |>
  filter(NUTS3 != "ΣΥΝΟΛΟ") |>
  select(-NUTS2) |>
  arrange(NUTS3, Year) |>
  group_by(NUTS3) |>
  mutate(
    Hotel_Arrivals_Natives_prev = lag(Hotel_Arrivals_Natives),
    Hotel_Arrivals_Foreign_prev = lag(Hotel_Arrivals_Foreign),
    Hotel_Arrivals_Total_prev = lag(Hotel_Arrivals_Total),
    Hotel_Beds_prev = lag(Hotel_Beds),
    Hotel_Arrivals_Natives_pct_diff = ifelse(is.na(Hotel_Arrivals_Natives_prev), NA, ((Hotel_Arrivals_Natives - Hotel_Arrivals_Natives_prev) / Hotel_Arrivals_Natives_prev) * 100),
    Hotel_Arrivals_Foreign_pct_diff = ifelse(is.na(Hotel_Arrivals_Foreign_prev), NA, ((Hotel_Arrivals_Foreign - Hotel_Arrivals_Foreign_prev) / Hotel_Arrivals_Foreign_prev) * 100),
    Hotel_Arrivals_Total_pct_diff = ifelse(is.na(Hotel_Arrivals_Total_prev), NA, ((Hotel_Arrivals_Total - Hotel_Arrivals_Total_prev) / Hotel_Arrivals_Total_prev) * 100),
    Hotel_Beds_pct_diff = ifelse(is.na(Hotel_Beds_prev), NA, ((Hotel_Beds - Hotel_Beds_prev) / Hotel_Beds_prev) * 100)
  ) |>
  ungroup() |>
  select(-ends_with("_prev")) |>
  rename("NUTS_name" = "NUTS3") |>
  mutate(NUTS_level = 3)

d <- rbind(d_ss27_NUTS2, d_ss27_NUTS3) |>
  rename("year" = "Year") |>
  relocate(NUTS_name, .before=everything()) |>
  relocate(NUTS_level, .after=NUTS_name) |>
  relocate(year, .after=NUTS_level)

write_csv(d, "data/greek_tourism_Arrivals.csv")
