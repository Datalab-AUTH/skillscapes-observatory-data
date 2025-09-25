# Data Quality Report (Non-Greek Merge — STACKED only)
_Generated: 2025-09-25T19:57:05Z_

## Pre-merge (per file)
### EU_labor_market_occupations_per_skill_level
- Rows: **82646**, Cols: **9**
- Year range: **2011 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **77095** (sample CSV saved)
- Top missingness: nuts_label: 100%, persons_per_skill_level: 9%, NUTS_name: 3%, Country_code: 2%, year: 0%
- Missingness CSV: `_dq_eu/EU_labor_market_occupations_per_skill_level__missingness.csv`

### EU_labor_market_unemployment
- Rows: **2928**, Cols: **8**
- Year range: **2013 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'unemployment_diff': 1705}
- Top missingness: nuts_label: 100%, unemployment_diff: 12%, unemployment_pct: 3%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_eu/EU_labor_market_unemployment__missingness.csv`

### EU_labor_market_workforce_education
- Rows: **18819**, Cols: **9**
- Year range: **2008 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **12546** (sample CSV saved)
- Top missingness: nuts_label: 100%, education_level_pct_diff: 9%, education_level_pct: 3%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_eu/EU_labor_market_workforce_education__missingness.csv`

### EULaborMarket-SectoralEmployment
- Rows: **350336**, Cols: **11**
- Year range: **2008 – 2023**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **325312** (sample CSV saved)
- Non-negative violations: {'sector_employment_pct_diff': 100098}
- Top missingness: nuts_label: 100%, sector_employment_pct_diff: 27%, sector_employment_pct: 21%, sector_employment: 21%, total_employment: 5%
- Missingness CSV: `_dq_eu/EULaborMarket-SectoralEmployment__missingness.csv`

### EULaborMarket-TotalEmployment
- Rows: **6290**, Cols: **10**
- Year range: **2008 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'total_employment_pct_diff': 2090}
- Top missingness: nuts_label: 100%, total_employment_pct_diff: 9%, employed_pct: 4%, population: 4%, total_employment: 3%
- Missingness CSV: `_dq_eu/EULaborMarket-TotalEmployment__missingness.csv`

### precarious_involuntary_part_time_employment
- Rows: **1428**, Cols: **8**
- Year range: **1983 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'involuntary_part_time_employment_diff': 527}
- Top missingness: nuts_label: 100%, involuntary_part_time_employment_diff: 32%, involuntary_part_time_employment: 29%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_eu/precarious_involuntary_part_time_employment__missingness.csv`

### precarious_NEET
- Rows: **8609**, Cols: **8**
- Year range: **2000 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'unemployment_rate_pct_diff': 4541}
- Top missingness: nuts_label: 100%, unemployment_rate_pct_diff: 6%, unemployment_rate: 2%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_eu/precarious_NEET__missingness.csv`

### precarious_part_time_employment
- Rows: **9620**, Cols: **10**
- Year range: **1999 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'part_time_employment_diff': 3375}
- Top missingness: nuts_label: 100%, part_time_employment_diff: 10%, part_time_employment_pct: 8%, part_time_employment: 6%, population: 6%
- Missingness CSV: `_dq_eu/precarious_part_time_employment__missingness.csv`

### precarious_temporary_part_time_employment
- Rows: **1020**, Cols: **8**
- Year range: **1995 – 2024**
- Duplicate full rows: **0**
- Duplicate (geo,year) rows: **0**
- Non-negative violations: {'temporary_employment_diff': 411}
- Top missingness: nuts_label: 100%, temporary_employment_diff: 14%, temporary_employment: 10%, geo: 0%, geo_label: 0%
- Missingness CSV: `_dq_eu/precarious_temporary_part_time_employment__missingness.csv`

## Stacked summary
- Rows: **481335**, Cols: **33**
- Exact duplicates removed: **0**
- Duplicates removed ignoring only 'source': **361**
- Top missing columns: nuts_label: 100%, temporary_employment_diff: 100%, temporary_employment: 100%, involuntary_part_time_employment_diff: 100%, involuntary_part_time_employment: 100%, unemployment_diff: 99%, unemployment_pct: 99%, total_employment_pct_diff: 99%, employed_pct: 99%, unemployment_rate_pct_diff: 98%
- Full missingness CSV: `_dq_eu/stacked__missingness.csv`