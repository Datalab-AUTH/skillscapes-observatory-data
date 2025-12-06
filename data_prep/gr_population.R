#!/usr/bin/Rscript

library(tidyverse)
library(DBI)
library(RSQLite)

if (!exists('con_sqlite')) {
  con_sqlite <- dbConnect(RSQLite::SQLite(), "skillscapes.sqlite")
}

source('common_aggregate_nuts.R')

region_lookup <- tribble(
  ~region, ~geo,
  "ATTIKI", "EL30",
  "FORMER PERFECTURE OF DODEKANISOS", "EL421",
  "FORMER PERFECTURE OF KYKLADES3", "EL422",
  "REGIONAL UNIT OF  SPORADES", "EL613b",
  "REGIONAL UNIT OF ACHAIA", "EL632",
  "REGIONAL UNIT OF AITOLOAKARNANIA", "EL631",
  "REGIONAL UNIT OF ARGOLIDA", "EL651a",
  "REGIONAL UNIT OF ARKADIA", "EL651b",
  "REGIONAL UNIT OF ARTA", "EL541a",
  "REGIONAL UNIT OF CHALKIDIKI", "EL527",
  "REGIONAL UNIT OF CHANIA", "EL434",
  "REGIONAL UNIT OF CHIOS", "EL413",
  "REGIONAL UNIT OF DRAMA", "EL514",
  "REGIONAL UNIT OF EVROS", "EL511",
  "REGIONAL UNIT OF EVRYTANIA", "EL643",
  "REGIONAL UNIT OF EVVOIA", "EL642",
  "REGIONAL UNIT OF FLORINA", "EL533",
  "REGIONAL UNIT OF FOKIDA", "EL645",
  "REGIONAL UNIT OF FTHIOTIDA", "EL644",
  "REGIONAL UNIT OF GREVENA", "EL531a",
  "REGIONAL UNIT OF IKARIA", "EL412a",
  "REGIONAL UNIT OF ILEIA", "EL633",
  "REGIONAL UNIT OF IMATHIA", "EL521",
  "REGIONAL UNIT OF IOANNINA", "EL543",
  "REGIONAL UNIT OF IRAKLIO", "EL431",
  "REGIONAL UNIT OF ITHAKI", "EL623a",
  "REGIONAL UNIT OF KARDITSA", "EL611a",
  "REGIONAL UNIT OF KASTORIA", "EL532",
  "REGIONAL UNIT OF KAVALA", "EL515b",
  "REGIONAL UNIT OF KAVALA & THASOS", "EL515",
  "REGIONAL UNIT OF KEFALLINIA", "EL623b",
  "REGIONAL UNIT OF KEFALLINIA & ITHAKI", "EL623",
  "REGIONAL UNIT OF KERKYRA", "EL622",
  "REGIONAL UNIT OF KILKIS", "EL523",
  "REGIONAL UNIT OF KORINTHIA", "EL652",
  "REGIONAL UNIT OF KOZANI", "EL531b",
  "REGIONAL UNIT OF LAKONIA", "EL653a",
  "REGIONAL UNIT OF LARISA", "EL612",
  "REGIONAL UNIT OF LASITHI", "EL432",
  "REGIONAL UNIT OF LEFKADA", "EL624",
  "REGIONAL UNIT OF LESVOS", "EL411a",
  "REGIONAL UNIT OF LESVOS & LIMNOS", "EL411",
  "REGIONAL UNIT OF LIMNOS", "EL411b",
  "REGIONAL UNIT OF MAGNISIA", "EL613a",
  "REGIONAL UNIT OF MAGNISIA & SPORADES", "EL613",
  "REGIONAL UNIT OF MESSINIA", "EL653b",
  "REGIONAL UNIT OF PELLA", "EL524",
  "REGIONAL UNIT OF PIERIA", "EL525",
  "REGIONAL UNIT OF PREVEZA", "EL541b",
  "REGIONAL UNIT OF RETHYMNO", "EL433",
  "REGIONAL UNIT OF RODOPI", "EL513",
  "REGIONAL UNIT OF SAMOS", "EL412b",
  "REGIONAL UNIT OF SAMOS & IKARIA", "EL412",
  "REGIONAL UNIT OF SERRES", "EL526",
  "REGIONAL UNIT OF THASOS", "EL515a",
  "REGIONAL UNIT OF THESPROTIA", "EL542",
  "REGIONAL UNIT OF THESSALONIKI", "EL522",
  "REGIONAL UNIT OF TRIKALA", "EL611b",
  "REGIONAL UNIT OF VOIOTIA", "EL641",
  "REGIONAL UNIT OF XANTHI", "EL512",
  "REGIONAL UNIT OF ZAKYNTHOS", "EL621",
  "Π.Ε. ΑΝΔΡΟΥ", "EL422a",
  "Π.Ε. ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ", "EL301",
  "Π.Ε. ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ", "EL306",
  "Π.Ε. ΕΝΟΤΗΤΑ ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ", "EL305",
  "Π.Ε. ΕΝΟΤΗΤΑ ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ", "EL302",
  "Π.Ε. ΕΝΟΤΗΤΑ ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ", "EL304",
  "Π.Ε. ΘΗΡΑΣ", "EL422b",
  "Π.Ε. ΚΑΛΥΜΝΟΥ", "EL421a",
  "Π.Ε. ΚΑΡΠΑΘΟΥ", "EL421b",
  "Π.Ε. ΚΕΑΣ", "EL422c",
  "Π.Ε. ΚΩ", "EL421c",
  "Π.Ε. ΜΗΛΟΥ", "EL422d",
  "Π.Ε. ΜΥΚΟΝΟΥ", "EL422e",
  "Π.Ε. ΝΑΞΟΥ", "EL422f",
  "Π.Ε. ΠΑΡΟΥ", "EL422g",
  "Π.Ε. ΡΟΔΟΥ", "EL421d",
  "Π.Ε. ΣΥΡΟΥ", "EL422h",
  "Π.Ε. ΤΗΝΟΥ", "EL422i",
  "Π.Ε.ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ", "EL303"
)

d <- read_csv("ELSTAT/population_by_region.csv") |>
  left_join(region_lookup, by="region") |>
  select(-region) |>
  relocate(geo, .before=everything()) |>
  mutate(year = as.integer(year))

d_nuts3 <- aggregate_regional_to_nuts3(d, geo, year) |>
  rows_upsert(d, by=c("geo", "year"))
d_nuts2 <- aggregate_nuts3_to_nuts2(d_nuts3, geo, year)
d_nuts1 <- aggregate_nuts2_to_nuts1(d_nuts2, geo, year)
d_population <- rbind(d_nuts1, d_nuts2, d_nuts3)

dbWriteTable(con_sqlite, "gr_population", d, overwrite = TRUE)
