# SkillScapes Observatory Data

Data to be used in the Observatory are in the `data` directory.

The `data_csv` directory includes some preprocessed data that is further
processed by the included scrips to create the data in the `data` directory.
**Don't use the files in the data_csv directory.**
There is a list for the coding of these files at the end of this README.

## Greek Tourism Industry

### Ακαθάριστο Εγχώριο προϊόν (ΑΕΠ) για τον κλάδο GHI ως προς το σύνολο του ΑΕΠ ανά NUTS 2

* Dataset: `data/greek_tourism_GDP.csv`
* Σχόλια: Δεν υπάρχουν δεδομένα ανά κλάδο, μόνο συνολικά.

### Ακαθάριστη Προστιθέμενη Αξία σε κλάδους GHI ανά περιφέρεια

* Dataset: `data/greek_tourism_GVA.csv`

### Κύκλος εργασιών επιχειρήσεων φιλοξενίας και εστίασης ανά περιφέρεια, NUTS3 και περιφερειακή ενότητα

* Dataset: `data/greek_tourism_Turnover.csv`
* Σχόλια: Δεδομένα από το 2019 μόνο.

### Μερίδιο των Ακαθάριστων Επενδύσεων Παγίου Κεφαλαίου (ΑΕΠΚ) για τον κλάδο GHI ως προς το σύνολο των ΑΕΠΚ  ανά NUTS 2

* Dataset: `data/greek_tourism_GFCF.csv`

### Αριθμός αγγελιών τουρισμού ανά NUTS3 και NUTS2. (tourism-related job ads)

* Dataset: NA
* Σχόλια: Τα έχει μαζέψει ο Ηλίας αυτά.

### Αφίξεις, διανυκτερεύσεις και πληρότητα κλινών στα καταλύματα ξενοδοχειακού τύπου κατά Περιφερειακή ενότητα, NUTS3 και NUTS2

* Dataset: `data/greek_tourism_Arrivals.csv`
* Σχόλια: Ετήσια δεδομένα. Υπάρχουν μηνιαία δεδομένα στην ΕΛΣΤΑΤ αλλά είναι μόνο για NUTS2, όχι NUTS3

### Μέση Δαπάνη ανά διανυκτέρευση και ανά επίσκεψη για NUTS2

* Dataset: `data/greek_tourism_AvgExpenditureDuration.csv`

### Μέση Διάρκεια παραμονής NUTS2

* Dataset: `data/greek_tourism_Stays.csv`

## EU Labour Markets

### Συνολική απασχόληση (total employment)

* Dataset: `data/EULaborMarket-TotalEmployment.csv`

### Κλαδική απασχόληση (sectoral employment)

* Dataset: `data/EULaborMarket-SectoralEmployment.csv`

### Επίπεδο εκπαίδευσης Εργατικού Δυναμικού (Workforce educational attainment level)

* Dataset: `data/EULaborMarket-WorkforceEducation.csv`
* Σχόλια: Ηλικίες 25-64.

### Επίπεδο Δεξιοτήτων Εργατικού Δυναμικού (Occupations per skill level)

* Dataset: `data/EU_labor_market_occupations_per_skill_level.csv`

### Ανεργία (Unemployment)

* Dataset: `data/EU_labor_market_unemployment.csv`
* Σχόλια: Unemployment rates by NUTS2.

## Precarious Labour in the EU

### Mερική μισθωτή απασχόληση (part-time waged employment)

* Dataset: `data/precarious_part_time_employment.csv`

### Μη ηθελημένη μερική μισθωτή απασχόληση (involuntary part-time waged employment)

* Dataset: `data/precarious_involuntary_part_time_employment.csv`

### Προσωρινή απασχόληση (temporary employment)

* Dataset: `data/precarious_temporary_part_time_employment.csv`

### Δείκτης vFCA

* Dataset: NA
* Σχόλια: Δεν είμαι σίγουρος τι είναι αυτό. Αν έχει να κάνει με job vacancies, υπάρχουν δεδομένα.

### NEETs

* Dataset: `data/precarious_NEET.csv`

# Data coding

This is a list for the coding used for files in the `data_csv` directory. The
rest of the data are from Eurostat.

* SS21: επίπεδο δεξιοτήτων (πηγή: Reslab)
* SS23: Κύκλος εργασιών επιχειρήσεων φιλοξενίας και εστίασης ανά περιφερειακή ενότητα (πηγή: ΕΛΣΤΑΤ)
* SS24: ΑΕΠΚ σε κλαδους GHI ανά περιφέρεια (2000-2022) (πηγή: ΕΛΣΤΑΤ)
* SS25: Ακαθαριστη Προστιθεμενη Αξία σε κλάδους GHI ανά περιφέρεια (2000-2022) (πηγή: ΕΛΣΤΑΤ)
* SS27: Αφίξεις σε καταλύματα ξενοδοχειακα, ενοικιαζομενα, καμπινγκ (πίνακας 03 κάθε χρονιά) (πηγή: ΕΛΣΤΑΤ)
* SS28: Διανυκτερεύσεις (και αριθμός και κλίνες)σε καταλύματα ξενοδοχειακα, ενοικιαζομενα, καμπινγκ (πίνακας 04 κάθε χρονιά) (πηγή: ΕΛΣΤΑΤ)
* SS33: Average expediture per journey, Average expediture per overnight stay, Average duration of stay by NUTS 2 (πηγή: INSETE)
