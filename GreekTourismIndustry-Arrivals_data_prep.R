#!/usr/bin/Rscript

library(tidyverse)

normalize_NUTS_labels <- function(x) {
  x %>%
    str_to_upper() %>%
    str_replace_all("ΠΕΡΙΦΕΡΕΙΑΚΗ ΕΝΟΤΗΤΑ ", "") %>%
    str_replace_all("&", "ΚΑΙ") %>%
    str_trim()
}

nuts2_dict <- c(
  "Ανατολική Μακεδονία, Θράκη" = "EL51",
  "Κεντρική Μακεδονία" = "EL52",
  "Δυτική Μακεδονία" = "EL53",
  "Ήπειρος" = "EL54",
  "Θεσσαλία" = "EL61",
  "Ιόνια Νησιά" = "EL62",
  "Δυτική Ελλάδα" = "EL63",
  "Στερεά Ελλάδα" = "EL64",
  "Πελοπόννησος" = "EL65",
  "Αττική" = "EL30",
  "Βόρειο Αιγαίο" = "EL41",
  "Νότιο Αιγαίο" = "EL42",
  "Κρήτη" = "EL43"
)

nuts2_map <- c(
  "ΑΝΑΤΟΛΙΚΗ ΜΑΚΕΔΟΝΙΑ & ΘΡΑΚΗ" = "Ανατολική Μακεδονία, Θράκη",
  "ΑΝΑΤΟΛΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ ΚΑΙ ΘΡΑΚΗΣ" = "Ανατολική Μακεδονία, Θράκη",
  "ΑΤΤΙΚΗ" = "Αττική",
  "ΑΤΤΙΚΗΣ" = "Αττική",
  "ΒΟΡΕΙΟ ΑΙΓΑΙΟ" = "Βόρειο Αιγαίο",
  "ΒΟΡΕΙΟΥ ΑΙΓΑΙΟΥ" = "Βόρειο Αιγαίο",
  "ΔΥΤΙΚΗ ΕΛΛΑΔΑ" = "Δυτική Ελλάδα",
  "ΔΥΤΙΚΗΣ ΕΛΛΑΔΑΣ" = "Δυτική Ελλάδα",
  "ΔΥΤΙΚΗ ΜΑΚΕΔΟΝΙΑ" = "Δυτική Μακεδονία",
  "ΔΥΤΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ" = "Δυτική Μακεδονία",
  "ΗΠΕΙΡΟΣ" = "Ήπειρος",
  "ΗΠΕΙΡΟΥ" = "Ήπειρος",
  "ΘΕΣΣΑΛΙΑ" = "Θεσσαλία",
  "ΘΕΣΣΑΛΙΑΣ" = "Θεσσαλία",
  "ΙΟΝΙΑ ΝΗΣΙΑ" = "Ιόνια Νησιά",
  "ΙΟΝΙΩΝ ΝΗΣΩΝ" = "Ιόνια Νησιά",
  "ΚΕΝΤΡΙΚΗ ΜΑΚΕΔΟΝΙΑ" = "Κεντρική Μακεδονία",
  "ΚΕΝΤΡΙΚΗΣ ΜΑΚΕΔΟΝΙΑΣ" = "Κεντρική Μακεδονία",
  "ΚΡΗΤΗ" = "Κρήτη",
  "ΚΡΗΤΗΣ" = "Κρήτη",
  "ΝΟΤΙΟ ΑΙΓΑΙΟ" = "Νότιο Αιγαίο",
  "ΝΟΤΙΟΥ ΑΙΓΑΙΟΥ" = "Νότιο Αιγαίο",
  "ΠΕΛΟΠΟΝΝΗΣΟΣ" = "Πελοπόννησος",
  "ΠΕΛΟΠΟΝΝΗΣΟΥ" = "Πελοπόννησος",
  "ΣΤΕΡΕΑ ΕΛΛΑΔΑ" = "Στερεά Ελλάδα",
  "ΣΤΕΡΕΑΣ ΕΛΛΑΔΑΣ" = "Στερεά Ελλάδα"
)

nuts3_dict <- c(
  "Βόρειος Τομέας Αθηνών" = "EL301",
  "Δυτικός Τομέας Αθηνών" = "EL302",
  "Κεντρικός Τομέας Αθηνών" = "EL303",
  "Νότιος Τομέας Αθηνών" = "EL304",
  "Ανατολική Αττική" = "EL305",
  "Δυτική Αττική" = "EL306",
  "Πειραιάς" = "EL307",   # note: sometimes listed as "Πειραιάς, Νήσοι"
  "Νήσοι" = "EL307",
  "Λέσβος" = "EL411",
  "Λήμνος" = "EL411",
  "Ικαρία" = "EL412",
  "Σάμος" = "EL412",
  "Χίος" = "EL413",
  "Κάλυμνος" = "EL421",
  "Κάρπαθος – Ηρωική Νήσος Κάσος" = "EL421",
  "Κως" = "EL421",
  "Ρόδος" = "EL421",
  "Άνδρος" = "EL422",
  "Θήρα" = "EL422",
  "Κέα" = "EL422",
  "Μήλος" = "EL422",
  "Μύκονος" = "EL422",
  "Νάξος" = "EL422",
  "Πάρος" = "EL422",
  "Σύρος" = "EL422",
  "Τήνος" = "EL422",
  "Ηράκλειο" = "EL431",
  "Λασίθι" = "EL432",
  "Ρέθυμνο" = "EL433",
  "Χανιά" = "EL434",
  "Έβρος" = "EL511",
  "Ξάνθη" = "EL512",
  "Ροδόπη" = "EL513",
  "Δράμα" = "EL514",
  "Θάσος" = "EL515",
  "Καβάλα" = "EL515",
  "Ημαθία" = "EL521",
  "Θεσσαλονίκη" = "EL522",
  "Κιλκίς" = "EL523",
  "Πέλλα" = "EL524",
  "Πιερία" = "EL525",
  "Σέρρες" = "EL526",
  "Χαλκιδική" = "EL527",
  "Γρεβενά" = "EL531",
  "Κοζάνη" = "EL531",
  "Καστοριά" = "EL532",
  "Φλώρινα" = "EL533",
  "Άρτα" = "EL541",
  "Πρέβεζα" = "EL541",
  "Θεσπρωτία" = "EL542",
  "Ιωάννινα" = "EL543",
  "Καρδίτσα" = "EL611",
  "Τρίκαλα" = "EL611",
  "Λάρισα" = "EL612",
  "Μαγνησία" = "EL613",
  "Σποράδες" = "EL613",
  "Ζάκυνθος" = "EL621",
  "Κέρκυρα" = "EL622",
  "Ιθάκη" = "EL623",
  "Κεφαλληνία" = "EL623",
  "Λευκάδα" = "EL624",
  "Αιτωλοακαρνανία" = "EL631",
  "Αχαΐα" = "EL632",
  "Ηλεία" = "EL633",
  "Βοιωτία" = "EL641",
  "Εύβοια" = "EL642",
  "Ευρυτανία" = "EL643",
  "Φθιώτιδα" = "EL644",
  "Φωκίδα" = "EL645",
  "Αργολίδα" = "EL651",
  "Αρκαδία" = "EL651",
  "Κορινθία" = "EL652",
  "Λακωνία" = "EL653",
  "Μεσσηνία" = "EL653"
)

nuts3_map <- c(
  "ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ" = "Αιτωλοακαρνανία",
  "ΑΙΤ/ΝΙΑΣ" = "Αιτωλοακαρνανία",
  "ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ" = "Ανατολική Αττική",
  "ΑΝΔΡΟΥ" = "Άνδρος",
  "ΑΡΓΟΛΙΔΑΣ" = "Αργολίδα",
  "ΑΡΚΑΔΙΑΣ" = "Αρκαδία",
  "ΑΡΤΑΣ" = "Άρτα",
  "ΑΧΑΪΑΣ" = "Αχαΐα",
  "ΑΧΑΙΑΣ" = "Αχαΐα",
  "ΒΟΙΩΤΙΑΣ" = "Βοιωτία",
  "ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ" = "Βόρειος Τομέας Αθηνών",
  "ΓΡΕΒΕΝΩΝ" = "Γρεβενά",
  "ΔΡΑΜΑΣ" = "Δράμα",
  "ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ" = "Δυτική Αττική",
  "ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ" = "Δυτικός Τομέας Αθηνών",
  "ΕΒΡΟΥ" = "Έβρος",
  "ΕΥΒΟΙΑΣ" = "Εύβοια",
  "ΕΥΡΥΤΑΝΙΑΣ" = "Ευρυτανία",
  "ΖΑΚΥΝΘΟΥ" = "Ζάκυνθος",
  "ΗΛΕΙΑΣ" = "Ηλεία",
  "ΗΜΑΘΙΑΣ" = "Ημαθία",
  "ΗΡΑΚΛΕΙΟΥ" = "Ηράκλειο",
  "ΘΑΣΟΥ" = "Θάσος",
  "ΘΕΣΠΡΩΤΙΑΣ" = "Θεσπρωτία",
  "ΘΕΣΣΑΛΟΝΙΚΗΣ" = "Θεσσαλονίκη",
  "ΘΗΡΑΣ" = "Θήρα",
  "ΙΘΑΚΗΣ" = "Ιθάκη",
  "ΙΚΑΡΙΑΣ" = "Ικαρία",
  "ΙΩΑΝΝΙΝΩΝ" = "Ιωάννινα",
  "ΚΑΒΑΛΑΣ" = "Καβάλα",
  "ΚΑΛΥΜΝΟΥ" = "Κάλυμνος",
  "ΚΑΡΔΙΤΣΑΣ" = "Καρδίτσα",
  "ΚΑΡΠΑΘΟΥ - ΗΡΩΙΚΗΣ ΝΗΣΟΥ ΚΑΣΟΥ" = "Κάρπαθος – Ηρωική Νήσος Κάσος",
  "ΚΑΡΠΑΘΟΥ" = "Κάρπαθος – Ηρωική Νήσος Κάσος",
  "ΚΑΣΤΟΡΙΑΣ" = "Καστοριά",
  "ΚΕΑΣ - ΚΥΘΝΟΥ" = "Κέα, Κύθνος",
  "ΚΕΑΣ-ΚΥΘΝΟΥ" = "Κέα, Κύθνος",
  "ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ" = "Κεντρικός Τομέας Αθηνών",
  "ΚΕΡΚΥΡΑΣ" = "Κέρκυρα",
  "ΚΕΦΑΛΛΗΝΙΑΣ" = "Κεφαλληνία",
  "ΚΙΛΚΙΣ" = "Κιλκίς",
  "ΚΟΖΑΝΗΣ" = "Κοζάνη",
  "ΚΟΡΙΝΘΙΑΣ" = "Κορινθία",
  "ΚΩ" = "Κως",
  "ΛΑΚΩΝΙΑΣ" = "Λακωνία",
  "ΛΑΡΙΣΑΣ" = "Λάρισα",
  "ΛΑΣΙΘΙΟΥ" = "Λασίθι",
  "ΛΕΣΒΟΥ" = "Λέσβος",
  "ΛΕΥΚΑΔΑΣ" = "Λευκάδα",
  "ΛΗΜΝΟΥ" = "Λήμνος",
  "ΜΑΓΝΗΣΙΑΣ" = "Μαγνησία",
  "ΜΕΣΣΗΝΙΑΣ" = "Μεσσηνία",
  "ΜΗΛΟΥ" = "Μήλος",
  "ΜΥΚΟΝΟΥ" = "Μύκονος",
  "ΝΑΞΟΥ" = "Νάξος",
  "ΝΗΣΩΝ" = "Νήσοι",
  "ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ" = "Νότιος Τομέας Αθηνών",
  "ΞΑΝΘΗΣ" = "Ξάνθη",
  "ΠΑΡΟΥ" = "Πάρος",
  "ΠΕΙΡΑΙΩΣ" = "Πειραιάς",
  "ΠΕΛΛΑΣ" = "Πέλλα",
  "ΠΙΕΡΙΑΣ" = "Πιερία",
  "ΠΡΕΒΕΖΑΣ" = "Πρέβεζα",
  "ΡΕΘΥΜΝΟΥ" = "Ρέθυμνο",
  "ΡΟΔΟΠΗΣ" = "Ροδόπη",
  "ΡΟΔΟΥ" = "Ρόδος",
  "ΣΑΜΟΥ" = "Σάμος",
  "ΣΕΡΡΩΝ" = "Σέρρες",
  "ΣΠΟΡΑΔΩΝ" = "Σποράδες",
  "ΣΥΡΟΥ" = "Σύρος",
  "ΤΗΝΟΥ" = "Τήνος",
  "ΤΡΙΚΑΛΩΝ" = "Τρίκαλα",
  "ΦΘΙΩΤΙΔΑΣ" = "Φθιώτιδα",
  "ΦΛΩΡΙΝΑΣ" = "Φλώρινα",
  "ΦΩΚΙΔΑΣ" = "Φωκίδα",
  "ΧΑΛΚΙΔΙΚΗΣ" = "Χαλκιδική",
  "ΧΑΝΙΩΝ" = "Χανιά",
  "ΧΙΟΥ" = "Χίος"
)

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
  mutate(NUTS_level = 2) |>
  mutate(NUTS_label_norm = recode(NUTS_name, !!!nuts2_map)) |>
  mutate(geo = recode(NUTS_label_norm, !!!nuts2_dict))
  
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
  mutate(NUTS_level = 3) |>
  mutate(NUTS_name = normalize_NUTS_labels(NUTS_name)) |>
  mutate(NUTS_label_norm = recode(NUTS_name, !!!nuts3_map)) |>
  mutate(geo = recode(NUTS_label_norm, !!!nuts3_dict))

d <- rbind(d_ss27_NUTS2, d_ss27_NUTS3) |>
  rename("year" = "Year") |>
  relocate(NUTS_name, .before=everything()) |>
  relocate(NUTS_level, .after=NUTS_name) |>
  relocate(year, .after=NUTS_level) |>
  select(-NUTS_name) |>
  rename("NUTS_label" = "NUTS_label_norm") |>
  relocate(NUTS_label, .before=everything()) |>
  relocate(geo, .before=everything())

write_csv(d, "data/greek_tourism_Arrivals.csv")
