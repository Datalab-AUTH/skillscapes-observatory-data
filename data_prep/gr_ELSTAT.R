#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

nuts1_dict <- c(
  "Αττική" = "EL3",
  "Βόρεια Ελλάδα" = "EL5",
  "Κεντρική Ελλάδα" = "EL6",
  "Νησιά Αιγαίου, Κρήτη" = "EL4"
)

nuts2_dict <- c(
  "ΑΝΑΤΟΛΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ ΚΑΙ ΘΡΑΚΗΣ" = "EL51",
  "ΑΤΤΙΚΗΣ" = "EL30",
  "ΒΟΡΕΙΟΥ ΑΙΓΑΙΟΥ" = "EL41",
  "ΔΥΤΙΚΗΣ ΕΛΛΑΔΑΣ" = "EL63",
  "ΔΥΤΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ" = "EL53",
  "ΗΠΕΙΡΟΥ" = "EL54",
  "ΘΕΣΣΑΛΙΑΣ" = "EL61",
  "ΙΟΝΙΩΝ ΝΗΣΩΝ" = "EL62",
  "ΚΕΝΤΡΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ" = "EL52",
  "ΚΡΗΤΗΣ" = "EL43",
  "ΝΟΤΙΟΥ ΑΙΓΑΙΟΥ" = "EL42",
  "ΠΕΛΟΠΟΝΝΗΣΟΥ" = "EL65",
  "ΣΤΕΡΕΑΣ ΕΛΛΑΔΑΣ" = "EL64"
)

nuts3_dict <- c(
  "ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ" = "EL631",
  "ΑΝΔΡΟΥ" = "EL422",
  "ΑΡΓΟΛΙΔΑΣ" = "EL651",
  "ΑΡΚΑΔΙΑΣ" = "EL651",
  "ΑΡΤΑΣ" = "EL541",
  "ΑΤΤΙΚΗΣ" = "EL30",
  "ΑΧΑΪΑΣ" = "EL632",
  "ΒΟΙΩΤΙΑΣ" = "EL641",
  "ΓΡΕΒΕΝΩΝ" = "EL531",
  "ΔΡΑΜΑΣ" = "EL514",
  "ΕΒΡΟΥ" = "EL511",
  "ΕΥΒΟΙΑΣ" = "EL642",
  "ΕΥΡΥΤΑΝΙΑΣ" = "EL643",
  "ΖΑΚΥΝΘΟΥ" = "EL621",
  "ΗΛΕΙΑΣ" = "EL633",
  "ΗΜΑΘΙΑΣ" = "EL521",
  "ΗΡΑΚΛΕΙΟΥ" = "EL431",
  "ΘΑΣΟΥ" = "EL515",
  "ΘΕΣΠΡΩΤΙΑΣ" = "EL542",
  "ΘΕΣΣΑΛΟΝΙΚΗΣ" = "EL522",
  "ΘΗΡΑΣ" = "EL422",
  "ΙΘΑΚΗΣ" = "EL623",
  "ΙΚΑΡΙΑΣ" = "EL412",
  "ΙΩΑΝΝΙΝΩΝ" = "EL543",
  "ΚΑΒΑΛΑΣ" = "EL515",
  "ΚΑΛΥΜΝΟΥ" = "EL421",
  "ΚΑΡΔΙΤΣΑΣ" = "EL611",
  "ΚΑΡΠΑΘΟΥ" = "EL421",
  "ΚΑΣΤΟΡΙΑΣ" = "EL532",
  "ΚΕΑΣ - ΚΥΘΝΟΥ" = "EL422",
  "ΚΕΡΚΥΡΑΣ" = "EL622",
  "ΚΕΦΑΛΛΗΝΙΑΣ" = "EL623",
  "ΚΙΛΚΙΣ" = "EL523",
  "ΚΟΖΑΝΗΣ" = "EL531",
  "ΚΟΡΙΝΘΙΑΣ" = "EL652",
  "ΚΩ" = "EL421",
  "ΛΑΚΩΝΙΑΣ" = "EL653",
  "ΛΑΡΙΣΑΣ" = "EL612",
  "ΛΑΣΙΘΙΟΥ" = "EL432",
  "ΛΕΣΒΟΥ" = "EL411",
  "ΛΕΥΚΑΔΑΣ" = "EL624",
  "ΛΗΜΝΟΥ" = "EL411",
  "ΜΑΓΝΗΣΙΑΣ" = "EL613",
  "ΜΕΣΣΗΝΙΑΣ" = "EL653",
  "ΜΗΛΟΥ" = "EL422",
  "ΜΥΚΟΝΟΥ" = "EL422",
  "ΝΑΞΟΥ" = "EL422",
  "ΞΑΝΘΗΣ" = "EL512",
  "ΠΑΡΟΥ" = "EL422",
  "ΠΕΛΛΑΣ" = "EL524",
  "ΠΙΕΡΙΑΣ" = "EL525",
  "ΠΡΕΒΕΖΑΣ" = "EL541",
  "ΡΕΘΥΜΝΟΥ" = "EL433",
  "ΡΟΔΟΠΗΣ" = "EL513",
  "ΡΟΔΟΥ" = "EL421",
  "ΣΑΜΟΥ" = "EL412",
  "ΣΕΡΡΩΝ" = "EL526",
  "ΣΠΟΡΑΔΩΝ" = "EL613",
  "ΣΥΡΟΥ" = "EL422",
  "ΤΗΝΟΥ" = "EL422",
  "ΤΡΙΚΑΛΩΝ" = "EL611",
  "ΦΘΙΩΤΙΔΑΣ" = "EL644",
  "ΦΛΩΡΙΝΑΣ" = "EL533",
  "ΦΩΚΙΔΑΣ" = "EL645",
  "ΧΑΛΚΙΔΙΚΗΣ" = "EL527",
  "ΧΑΝΙΩΝ" = "EL434",
  "ΧΙΟΥ" = "EL413"
)


d_elstat <- read_csv('ELSTAT/ELSTAT_SBR03.csv')

d_elstat_NUTS2 <- d_elstat |>
  select(-NUTS3) |>
  arrange(NUTS2, Year) |>
  group_by(NUTS2, Year) |>
  summarize(Turnover_Catering = sum(Turnover_Catering, na.rm = TRUE),
            Turnover_Accomodation = sum(Turnover_Accomodation, na.rm = TRUE)) |>
  ungroup() |>
  rename("NUTS_label" = "NUTS2") |>
  mutate(NUTS_level = 2) |>
  mutate(geo = recode(NUTS_label, !!!nuts2_dict))

d_elstat_NUTS3 <- d_elstat |>
  select(-NUTS2) |>
  arrange(NUTS3, Year) |>
  rename("NUTS_label" = "NUTS3") |>
  mutate(NUTS_level = 3) |>
  mutate(geo = recode(NUTS_label, !!!nuts3_dict))

d_elstat_NUTS1 <- d_elstat |>
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
  mutate(NUTS_level = 1) |>
  mutate(geo = recode(NUTS_label, !!!nuts1_dict))

d <- rbind(d_elstat_NUTS1, d_elstat_NUTS2, d_elstat_NUTS3) |>
  rename("year" = "Year") |>
  arrange(NUTS_level, NUTS_label, year) |>
  select(-NUTS_label, -NUTS_level) |>
  relocate(geo, .before=year) |>
  filter(geo != "ΑΤΤΙΚΗΣ*") |> # There are not NUTS3 data for Attiki
  rename(
    "turnover_catering" = "Turnover_Catering",
    "turnover_accommodation" = "Turnover_Accomodation"
  ) |>
  mutate(
    turnover_total = turnover_catering + turnover_accommodation,
    year = as.integer(year)
    )
dbWriteTable(con_sqlite, "gr_elstat", d, overwrite = TRUE)
