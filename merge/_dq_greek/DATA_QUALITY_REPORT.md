# Data Quality Report (Greek Merge — STACKED only)
_Generated: 2025-09-25T20:00:51Z_

## Pre-merge (per file)
### greek_tourism_Arrivals
- Rows: **783**, Cols: **12**
- Year range: **2015 – 2023**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **189** (sample CSV saved)
- Non-negative violations: {'Hotel_Arrivals_Natives_pct_diff': 200, 'Hotel_Arrivals_Foreign_pct_diff': 168, 'Hotel_Arrivals_Total_pct_diff': 171, 'Hotel_Beds_pct_diff': 279}
- Top missingness: Hotel_Arrivals_Natives_pct_diff: 11%, Hotel_Arrivals_Foreign_pct_diff: 11%, Hotel_Arrivals_Total_pct_diff: 11%, Hotel_Beds_pct_diff: 11%, year: 0%
- Missingness CSV: `_dq_greek/greek_tourism_Arrivals__missingness.csv`

### greek_tourism_AvgExpenditureDuration
- Rows: **117**, Cols: **10**
- Year range: **2016 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Top missingness: Avg_duration_of_stay_pct_diff: 11%, Avg_expenditure_per_stay_pct_diff: 11%, Avg_expenditure_per_journey_pct_diff: 11%, geo: 0%, nuts_label: 0%
- Missingness CSV: `_dq_greek/greek_tourism_AvgExpenditureDuration__missingness.csv`

### greek_tourism_GDP
- Rows: **7168**, Cols: **6**
- Year range: **2008 – 2023**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'GDP_pct_diff': 1991}
- Top missingness: nuts_label: 100%, GDP_pct_diff: 2%, GDP: 1%, nuts_level: 0%, geo: 0%
- Missingness CSV: `_dq_greek/greek_tourism_GDP__missingness.csv`

### greek_tourism_GFCF
- Rows: **391**, Cols: **9**
- Year range: **2000 – 2022**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'GFCF_pct_diff': 164}
- Top missingness: GFCF_pct_diff: 4%, geo: 0%, nuts_label: 0%, nuts_level: 0%, NUTS_label_el: 0%
- Missingness CSV: `_dq_greek/greek_tourism_GFCF__missingness.csv`

### greek_tourism_GVA
- Rows: **1702**, Cols: **8**
- Year range: **2000 – 2022**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **115** (sample CSV saved)
- Non-negative violations: {'GVA_GHI_pct_diff': 658}
- Top missingness: GVA_GHI_pct_diff: 4%, geo: 0%, nuts_level: 0%, nuts_label: 0%, year: 0%
- Missingness CSV: `_dq_greek/greek_tourism_GVA__missingness.csv`

### greek_tourism_Stays
- Rows: **869**, Cols: **13**
- Year range: **2015 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **210** (sample CSV saved)
- Non-negative violations: {'Hotel_Stays_Natives_pct_diff': 221, 'Hotel_Stays_Foreign_pct_diff': 179, 'Hotel_Stays_Total_pct_diff': 183}
- Top missingness: Hotel_Occupancy_pct_diff: 20%, Hotel_Stays_Natives_pct_diff: 20%, Hotel_Stays_Foreign_pct_diff: 20%, Hotel_Stays_Total_pct_diff: 20%, geo: 0%
- Missingness CSV: `_dq_greek/greek_tourism_Stays__missingness.csv`

### greek_tourism_Turnover
- Rows: **504**, Cols: **8**
- Year range: **2019 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **132** (sample CSV saved)
- Non-negative violations: {'Turnover_Catering_pct_diff': 99, 'Turnover_Accomodation_pct_diff': 96}
- Top missingness: Turnover_Accomodation_pct_diff: 19%, Turnover_Catering_pct_diff: 17%, Turnover_Accomodation: 1%, Turnover_Catering: 0%, year: 0%
- Missingness CSV: `_dq_greek/greek_tourism_Turnover__missingness.csv`

## Stacked summary
- Rows: **11534**, Cols: **42**
- Exact duplicates removed: **0**
- Duplicates removed ignoring only 'source': **0**
- Top missing columns: Avg_expenditure_per_stay_pct_diff: 99%, Avg_expenditure_per_journey_pct_diff: 99%, Avg_duration_of_stay_pct_diff: 99%, Avg_expenditure_per_journey: 99%, Avg_duration_of_stay: 99%, Avg_expenditure_per_stay: 99%, GFCF_pct_diff: 97%, GFCF_GHI: 97%, GFCF_pct: 97%, GFCF_Total: 97%
- Full missingness CSV: `_dq_greek/stacked__missingness.csv`