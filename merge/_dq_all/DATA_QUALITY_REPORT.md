# Data Quality Report (ALL → STACKED)
_Generated: 2025-09-25T20:34:29Z_

## Pre-merge (per file)
### EU_labor_market_occupations_per_skill_level
- Rows: **82646**, Cols: **9**
- Year range: **2011 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **77095** (sample CSV saved)
- Top missingness: nuts_label: 100%, persons_per_skill_level: 9%, NUTS_name: 3%, Country_code: 2%, year: 0%
- Missingness CSV: `_dq_all/EU_labor_market_occupations_per_skill_level__missingness.csv`

### EU_labor_market_unemployment
- Rows: **2928**, Cols: **8**
- Year range: **2013 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'unemployment_diff': 1705}
- Top missingness: nuts_label: 100%, unemployment_diff: 12%, unemployment_pct: 3%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_all/EU_labor_market_unemployment__missingness.csv`

### EU_labor_market_workforce_education
- Rows: **18819**, Cols: **9**
- Year range: **2008 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **12546** (sample CSV saved)
- Top missingness: nuts_label: 100%, education_level_pct_diff: 9%, education_level_pct: 3%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_all/EU_labor_market_workforce_education__missingness.csv`

### EULaborMarket-SectoralEmployment
- Rows: **350336**, Cols: **11**
- Year range: **2008 – 2023**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **325312** (sample CSV saved)
- Non-negative violations: {'sector_employment_pct_diff': 100098}
- Top missingness: nuts_label: 100%, sector_employment_pct_diff: 27%, sector_employment_pct: 21%, sector_employment: 21%, total_employment: 5%
- Missingness CSV: `_dq_all/EULaborMarket-SectoralEmployment__missingness.csv`

### EULaborMarket-TotalEmployment
- Rows: **6290**, Cols: **10**
- Year range: **2008 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'total_employment_pct_diff': 2090}
- Top missingness: nuts_label: 100%, total_employment_pct_diff: 9%, employed_pct: 4%, population: 4%, total_employment: 3%
- Missingness CSV: `_dq_all/EULaborMarket-TotalEmployment__missingness.csv`

### greek_tourism_Arrivals
- Rows: **783**, Cols: **12**
- Year range: **2015 – 2023**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **189** (sample CSV saved)
- Non-negative violations: {'Hotel_Arrivals_Natives_pct_diff': 200, 'Hotel_Arrivals_Foreign_pct_diff': 168, 'Hotel_Arrivals_Total_pct_diff': 171, 'Hotel_Beds_pct_diff': 279}
- Top missingness: Hotel_Arrivals_Natives_pct_diff: 11%, Hotel_Arrivals_Foreign_pct_diff: 11%, Hotel_Arrivals_Total_pct_diff: 11%, Hotel_Beds_pct_diff: 11%, year: 0%
- Missingness CSV: `_dq_all/greek_tourism_Arrivals__missingness.csv`

### greek_tourism_AvgExpenditureDuration
- Rows: **117**, Cols: **10**
- Year range: **2016 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Top missingness: Avg_duration_of_stay_pct_diff: 11%, Avg_expenditure_per_stay_pct_diff: 11%, Avg_expenditure_per_journey_pct_diff: 11%, geo: 0%, nuts_label: 0%
- Missingness CSV: `_dq_all/greek_tourism_AvgExpenditureDuration__missingness.csv`

### greek_tourism_GDP
- Rows: **7168**, Cols: **6**
- Year range: **2008 – 2023**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'GDP_pct_diff': 1991}
- Top missingness: nuts_label: 100%, GDP_pct_diff: 2%, GDP: 1%, nuts_level: 0%, geo: 0%
- Missingness CSV: `_dq_all/greek_tourism_GDP__missingness.csv`

### greek_tourism_GFCF
- Rows: **391**, Cols: **9**
- Year range: **2000 – 2022**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'GFCF_pct_diff': 164}
- Top missingness: GFCF_pct_diff: 4%, geo: 0%, nuts_label: 0%, nuts_level: 0%, NUTS_label_el: 0%
- Missingness CSV: `_dq_all/greek_tourism_GFCF__missingness.csv`

### greek_tourism_GVA
- Rows: **1702**, Cols: **8**
- Year range: **2000 – 2022**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **115** (sample CSV saved)
- Non-negative violations: {'GVA_GHI_pct_diff': 658}
- Top missingness: GVA_GHI_pct_diff: 4%, geo: 0%, nuts_level: 0%, nuts_label: 0%, year: 0%
- Missingness CSV: `_dq_all/greek_tourism_GVA__missingness.csv`

### greek_tourism_Stays
- Rows: **869**, Cols: **13**
- Year range: **2015 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **210** (sample CSV saved)
- Non-negative violations: {'Hotel_Stays_Natives_pct_diff': 221, 'Hotel_Stays_Foreign_pct_diff': 179, 'Hotel_Stays_Total_pct_diff': 183}
- Top missingness: Hotel_Occupancy_pct_diff: 20%, Hotel_Stays_Natives_pct_diff: 20%, Hotel_Stays_Foreign_pct_diff: 20%, Hotel_Stays_Total_pct_diff: 20%, geo: 0%
- Missingness CSV: `_dq_all/greek_tourism_Stays__missingness.csv`

### greek_tourism_Turnover
- Rows: **504**, Cols: **8**
- Year range: **2019 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **132** (sample CSV saved)
- Non-negative violations: {'Turnover_Catering_pct_diff': 99, 'Turnover_Accomodation_pct_diff': 96}
- Top missingness: Turnover_Accomodation_pct_diff: 19%, Turnover_Catering_pct_diff: 17%, Turnover_Accomodation: 1%, Turnover_Catering: 0%, year: 0%
- Missingness CSV: `_dq_all/greek_tourism_Turnover__missingness.csv`

### precarious_involuntary_part_time_employment
- Rows: **1428**, Cols: **8**
- Year range: **1983 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'involuntary_part_time_employment_diff': 527}
- Top missingness: nuts_label: 100%, involuntary_part_time_employment_diff: 32%, involuntary_part_time_employment: 29%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_all/precarious_involuntary_part_time_employment__missingness.csv`

### precarious_NEET
- Rows: **8609**, Cols: **8**
- Year range: **2000 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'unemployment_rate_pct_diff': 4541}
- Top missingness: nuts_label: 100%, unemployment_rate_pct_diff: 6%, unemployment_rate: 2%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_all/precarious_NEET__missingness.csv`

### precarious_part_time_employment
- Rows: **9620**, Cols: **10**
- Year range: **1999 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'part_time_employment_diff': 3375}
- Top missingness: nuts_label: 100%, part_time_employment_diff: 10%, part_time_employment_pct: 8%, part_time_employment: 6%, population: 6%
- Missingness CSV: `_dq_all/precarious_part_time_employment__missingness.csv`

### precarious_temporary_part_time_employment
- Rows: **1020**, Cols: **8**
- Year range: **1995 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'temporary_employment_diff': 411}
- Top missingness: nuts_label: 100%, temporary_employment_diff: 14%, temporary_employment: 10%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_all/precarious_temporary_part_time_employment__missingness.csv`

## Post-merge (STACKED)
- Rows: **492869**, Cols: **70**
- Top missing columns: Avg_expenditure_per_stay_pct_diff: 100%, Avg_expenditure_per_journey_pct_diff: 100%, Avg_duration_of_stay_pct_diff: 100%, Avg_expenditure_per_stay: 100%, Avg_duration_of_stay: 100%, Avg_expenditure_per_journey: 100%, GFCF_pct_diff: 100%, GFCF_Total: 100%, NUTS_label_el: 100%, GFCF_GHI: 100%
- Full CSV: `_dq_all/post__missingness.csv`
- Notable outlier rates (>5%): sector_employment (~7.3%), total_employment (~9.1%), sector_employment_pct_diff (~5.7%) (samples under `_dq_all/post__outliers__*.csv`)