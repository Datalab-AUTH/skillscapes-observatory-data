#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

if (!exists('d_gr_population')) {
  source('gr_population.R')
}
if (!exists('d_gr_land_area')) {
  source('gr_land_area.R')
}

source('common_aggregate_nuts.R')

NUTS2_lookup <- tribble(
  ~region, ~geo,
  "Attica",	"EL30",
  "Central Greece", "EL64",
  "Central Macedonia", "EL52",
  "Crete", "EL43",
  "Eastern Macedonia & Thrace", "EL51",
  "Epirus", "EL54",
  "Ionian Islands", "EL62",
  "North Aegean", "EL41",
  "Peloponnese", "EL65",
  "South Aegean", "EL42",
  "Thessaly", "EL61",
  "Western Greece", "EL63",
  "Western Macedonia", "EL53"
)

region_code_lookup <- tribble(
  ~region, ~geo,
  "Central Athens", "EL303",
  "East Attica", "EL305",
  "South Athens", "EL304",
  "Piraeus", "EL307a", # this is a typo in INSETE data
  "Pireaus", "EL307a", # this is the right one, also in INSETE data
  "Islands", "EL307b",
  "North Athens", "EL301",
  "West Attica", "EL306",
  "West Athens", "EL302",
  "ATTICA", "EL30",
  "Voiotia", "EL641",
  "Evia",  "EL642",
  "Evritania", "EL643",
  "Fthiotida", "EL644",
  "Fokida", "EL645",
  "CENTRAL GREECE", "EL64",
  "Imathia", "EL521",
  "Thessaloniki", "EL522",
  "Kilkis", "EL523",
  "Pella", "EL524",
  "Pieria", "EL525",
  "Serres", "EL526",
  "Halkidiki", "EL527",
  "CENTRAL MACEDONIA", "EL52",
  "Heraklion", "EL431",
  "Lasithi", "EL432",
  "Rethymno", "EL433",
  "Chania", "EL434",
  "CRETE", "EL43",
  "Drama", "EL514",
  "Evros", "EL511",
  "Thassos", "EL515a",
  "Kavala", "EL515b",
  "Xanthi", "EL512",
  "Rodopi", "EL513",
  "EASTERN MACEDONIA & THRACE", "EL51",
  "Arta", "EL541a",
  "Thesprotia", "EL542",
  "Ioannina", "EL543",
  "Preveza", "EL541b",
  "EPIRUS", "EL54",
  "Zante", "EL621",
  "Corfu", "EL622",
  "Ithaca", "EL623a",
  "Kefalonia", "EL623b",
  "Lefkada", "EL624",
  "IONIAN ISLANDS", "EL62",
  "Lesvos", "EL411a",
  "Lemnos", "EL411b",
  "Samos", "EL412b",
  "Icaria", "EL412a",
  "Chios", "EL413",
  "NORTH AEGEAN", "EL41",
  "Argolida", "EL651a",
  "Arkadia", "EL651b",
  "Korinthos", "EL652",
  "Lakonia", "EL653a",
  "Messinia", "EL653b",
  "PELOPONNESE", "EL65",
  "Syros", "EL422h",
  "Andros", "EL422a",
  "Thira", "EL422b",
  "Kea-Kythnos", "EL422c",   # this and the following one are duplicates,
  "Kea - Kythnos", "EL422c", # found both ways in INSETE data
  "Milos", "EL422d",
  "Mykonos", "EL422e",
  "Naxos", "EL422f",
  "Paros", "EL422g",
  "Tinos", "EL422i",
  "CYCLADES", "EL422",
  "Kalymnos", "EL421a",
  "Karpathos", "EL421b",
  "Kos", "EL421c",
  "Rhodes", "EL421d",
  "DODECANESE", "EL421",
  "Karditsa", "EL611a",
  "Sporades", "EL613b",
  "Magnesia", "EL613a",
  "Trikala", "EL611b",
  "THESSALY", "EL61",
  "Aitoloakarnania", "EL631",
  "Achaia", "EL632",
  "Ilia", "EL633",
  "WESTERN GREECE", "EL63",
  "Grevena", "EL531a",
  "Kastoria", "EL532",
  "Kozani", "EL531b",
  "Florina", "EL533",
  "WESTERN MACEDONIA", "EL53",
  "Larissa", "EL612", # another case of duplicates in INSETE data
  "Larisa", "EL612",
  "Kavala & Thassos", "EL515", 
  "SOUTH AEGEAN", "EL42"
)

# Only keep areas that are regions, not at NUTS level, so that we can use it
# in the gen_nuts.R script
d_region_codes <- region_code_lookup |>
  #filter(!str_detect(geo, "\\d$")) |>
  filter(str_length(geo) > 4) |> # remove NUTS2 entries
  filter(region != "DODECANESE") |> # these two are already in the gen_nuts as
  filter(region != "CYCLADES") |>   # NUTS3
  filter(region != "Piraeus") |> # typo on INSETE data
  filter(region != "Kavala & Thassos") |> # this is a problem with the Eastern Macedonia and Thrace data, "Hotel capacity" sheet, years 2011-2012
  rename("geo_label" = "region") |>
  group_by(geo) |> # for other duplicates, keep the first occurrence
  slice_head(n = 1) |>
  ungroup()
write_csv(d_region_codes, "region_codes_EL.csv")

# Employment - NUTS2

d_employment_nuts2 <- read_csv("INSETE/INSETE_employment.csv") |>
  left_join(NUTS2_lookup, by="region") |>
  select(-region) |>
  relocate(geo, .before=everything())
d_employment_nuts1 <- aggregate_nuts2_to_nuts1(d_employment_nuts2, geo, year)
d_employment_all <- rbind(d_employment_nuts1, d_employment_nuts2)

dbWriteTable(con_sqlite, "gr_insete_employment", d_employment_all, overwrite = TRUE)

# key figures - NUTS2

d_key_figures_nuts2 <- read_csv("INSETE/INSETE_key_figures.csv") |>
  left_join(NUTS2_lookup, by="region") |>
  select(-region) |>
  relocate(geo, .before=everything())
d_key_figures_nuts1 <- aggregate_nuts2_to_nuts1(d_key_figures_nuts2, geo, year)
d_key_figures_all <- rbind(d_key_figures_nuts1, d_key_figures_nuts2)

dbWriteTable(con_sqlite, "gr_insete_key_figures", d_key_figures_all, overwrite = TRUE)

# hotels - Regional units

d_hotels <- read_csv("INSETE/INSETE_hotels.csv") |>
  left_join(region_code_lookup, by="region") |>
  select(-region) |>
  pivot_wider(names_from = variable, values_from = value) |>
  mutate(
    hotels_total_arrivals = hotels_foreign_arrivals + hotels_domestic_arrivals,
    hotels_total_overnights = hotels_foreign_overnights + hotels_domestic_overnights,
    hotels_avg_duration_of_stay_foreign = hotels_foreign_overnights / hotels_foreign_arrivals,
    hotels_avg_duration_of_stay_domestic = hotels_domestic_overnights / hotels_domestic_arrivals,
    hotels_avg_duration_of_stay_total = hotels_total_overnights / hotels_total_arrivals
  )
d_hotels_remaining_nuts3 <- aggregate_regional_to_nuts3(
  d_hotels |> filter(!str_starts(geo, "EL421")) |> # we already have data for DODECANESE
        filter(!str_starts(geo, "EL422")),         # and CYCLADES
      geo, year)
# but we don't have data for South Aegean (EL42)...
d_hotels_EL421_EL422 <- d_hotels |>
  filter(geo == "EL421" | geo == "EL422")
d_hotels_EL42 <- aggregate_nuts3_to_nuts2(d_hotels_EL421_EL422, geo, year)
d_hotels_with_EL42 <- d_hotels |>
  rbind(d_hotels_EL42)
d_hotels_nuts1 <- aggregate_nuts2_to_nuts1(d_hotels_with_EL42, geo, year)
d_hotels_all <- d_hotels_with_EL42 |>
  rbind(d_hotels_remaining_nuts3) |>
  rbind(d_hotels_nuts1) |>
  relocate(geo, .before=everything()) |>
  left_join(d_gr_population, by=c("geo", "year")) |>
  left_join(d_gr_land_area, by="geo") |>
  mutate(
    hotels_foreign_arrivals_per_person = hotels_foreign_arrivals / population,
    hotels_foreign_arrivals_per_person = ifelse(is.infinite(hotels_foreign_arrivals_per_person), NA, hotels_foreign_arrivals_per_person), # there are zeros in the population data
    hotels_foreign_arrivals_per_km2 = hotels_foreign_arrivals / land_area,
    hotels_domestic_arrivals_per_person = hotels_domestic_arrivals / population,
    hotels_domestic_arrivals_per_person = ifelse(is.infinite(hotels_domestic_arrivals_per_person), NA, hotels_domestic_arrivals_per_person), # there are zeros in the population data
    hotels_domestic_arrivals_per_km2 = hotels_domestic_arrivals / land_area,
    hotels_total_arrivals_per_person = hotels_total_arrivals / population,
    hotels_total_arrivals_per_person = ifelse(is.infinite(hotels_total_arrivals_per_person), NA, hotels_total_arrivals_per_person), # there are zeros in the population data
    hotels_total_arrivals_per_km2 = hotels_total_arrivals / land_area
  ) |>
  select(-population, -land_area)

dbWriteTable(con_sqlite, "gr_insete_hotels", d_hotels_all, overwrite = TRUE)

# short stay - Regional units

d_short_stay <- read_csv("INSETE/INSETE_short_stay.csv") |>
  left_join(region_code_lookup, by="region") |>
  select(-region) |>
  pivot_wider(names_from = variable, values_from = value) |>
  mutate(
    short_stay_total_arrivals = short_stay_foreign_arrivals + short_stay_domestic_arrivals,
    short_stay_total_overnights = short_stay_foreign_overnights + short_stay_domestic_overnights,
    short_stay_avg_duration_of_stay_foreign = short_stay_foreign_overnights / short_stay_foreign_arrivals,
    short_stay_avg_duration_of_stay_domestic = short_stay_domestic_overnights / short_stay_domestic_arrivals,
    short_stay_avg_duration_of_stay_total = short_stay_total_overnights / short_stay_total_arrivals
  ) |>
  mutate(across(everything(), ~ ifelse(is.nan(.), NA, .)))
d_short_stay_remaining_nuts3 <- aggregate_regional_to_nuts3(
  d_short_stay |> filter(!str_starts(geo, "EL421")) |> # we already have data for DODECANESE
    filter(!str_starts(geo, "EL422")),                 # and CYCLADES
  geo, year)
d_short_stay_nuts1 <- aggregate_nuts2_to_nuts1(d_short_stay, geo, year)
d_short_stay_all <- d_short_stay |>
  rbind(d_short_stay_remaining_nuts3) |>
  rbind(d_short_stay_nuts1) |>
  relocate(geo, .before=everything()) |>
  left_join(d_gr_population, by=c("geo", "year")) |>
  left_join(d_gr_land_area, by="geo") |>
  mutate(
    short_stay_foreign_arrivals_per_person = short_stay_foreign_arrivals / population,
    short_stay_foreign_arrivals_per_person = ifelse(is.infinite(short_stay_foreign_arrivals_per_person), NA, short_stay_foreign_arrivals_per_person), # there are zeros in the population data
    short_stay_foreign_arrivals_per_km2 = short_stay_foreign_arrivals / land_area,
    short_stay_domestic_arrivals_per_person = short_stay_domestic_arrivals / population,
    short_stay_domestic_arrivals_per_person = ifelse(is.infinite(short_stay_domestic_arrivals_per_person), NA, short_stay_domestic_arrivals_per_person), # there are zeros in the population data
    short_stay_domestic_arrivals_per_km2 = short_stay_domestic_arrivals / land_area,
    short_stay_total_arrivals_per_person = short_stay_total_arrivals / population,
    short_stay_total_arrivals_per_person = ifelse(is.infinite(short_stay_total_arrivals_per_person), NA, short_stay_total_arrivals_per_person), # there are zeros in the population data
    short_stay_total_arrivals_per_km2 = short_stay_total_arrivals / land_area
  ) |>
  select(-population, -land_area)

dbWriteTable(con_sqlite, "gr_insete_short_stay", d_short_stay_all, overwrite = TRUE)

# Hotel Capacity - Regional units

d_hotel_capacity <- read_csv("INSETE/INSETE_hotel_capacity.csv") |>
  left_join(region_code_lookup, by="region") |>
  select(-region) |>
  filter(year > 2013) |> # data until 2013 had weird regions, like "Saronic Islands", "Laconic Islands" and "Rest of Attica"
  pivot_wider(names_from = variable, values_from = value)
d_hotel_capacity_remaining_nuts3 <- aggregate_regional_to_nuts3(d_hotel_capacity, geo, year)
d_hotel_capacity_with_nuts3 <- d_hotel_capacity |>
  rbind(d_hotel_capacity_remaining_nuts3)
d_hotel_capacity_nuts3 <- d_hotel_capacity |>
  filter(str_length(geo) == 5) |>
  rbind(d_hotel_capacity_remaining_nuts3)
d_hotel_capacity_nuts1 <- aggregate_nuts2_to_nuts1(d_hotel_capacity, geo, year)
d_hotel_capacity_all <- d_hotel_capacity |>
  rbind(d_hotel_capacity_remaining_nuts3) |>
  rbind(d_hotel_capacity_nuts1) |>
  relocate(geo, .before=everything()) |>
  left_join(d_gr_population, by=c("geo", "year")) |>
  left_join(d_gr_land_area, by="geo") |>
  mutate(
    guest_beds_per_person = guest_beds / population,
    guest_beds_per_person = ifelse(is.infinite(guest_beds_per_person), NA, guest_beds_per_person), # there are zeros in the population data
    guest_beds_per_km2 = guest_beds / land_area
  ) |>
  select(-population, -land_area)

dbWriteTable(con_sqlite, "gr_insete_hotel_capacity", d_hotel_capacity_all, overwrite = TRUE)

# STR - Regional units

d_STR <- read_csv("INSETE/INSETE_STR.csv") |>
  left_join(region_code_lookup, by="region") |>
  select(-region) |>
  mutate(year_month = year * 100 + month) |> # combine the year and month columns in order to aggregate them
  select(-year, -month)
d_STR_remaining_nuts3 <- aggregate_regional_to_nuts3(d_STR, geo, year_month)
d_STR_nuts3 <- d_STR |>
  rbind(d_STR_remaining_nuts3)
d_STR_nuts2 <- aggregate_nuts3_to_nuts2(d_STR_nuts3, geo, year_month)
d_STR_nuts1 <- aggregate_nuts2_to_nuts1(d_STR_nuts2, geo, year_month)
d_STR_all <- d_STR_nuts3 |>
  rbind(d_STR_nuts2) |>
  rbind(d_STR_nuts1) |>
  mutate( # un-combine the year and month columns
    year = as.integer(year_month / 100),
    month = as.integer(year_month - 100 * year)
  ) |>
  select(-year_month) |>
  relocate(geo, .before=everything()) |>
  relocate(STR_accommodation_beds, .after=everything())
dbWriteTable(con_sqlite, "gr_insete_STR", d_STR_all, overwrite = TRUE)

# The STR data are monthly. We need them on a yearly basis. We'll keep the max value.
d_STR_yearly <- d_STR_all |>
  select(-month) |>
  group_by(geo, year) |>
  summarize(STR_accommodation_beds = max(STR_accommodation_beds, na.rm = TRUE)) |>
  ungroup()

dbWriteTable(con_sqlite, "gr_insete_STR_yearly", d_STR_yearly, overwrite = TRUE)


