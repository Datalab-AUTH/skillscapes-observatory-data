# SkillScapes Observatory Data

This repository contains the data pipeline for the SkillScapes Observatory. It
collects regional labour market and economic data from multiple sources —
ELSTAT, INSETE, Eurostat, and the Reslab microdata application — and produces a
SQLite database (`skillscapes.sqlite`) used by the Observatory.

## Prerequisites

- A Linux system with Docker installed and running
- The `datalabauth/skillscapes-python` and `datalabauth/skillscapes-r` Docker
  images available locally
- Access to the Reslab PostgreSQL database at the University of the Aegean,
  with read permissions on the following tables:
  - `rslb_user.b41_empl_data_abs`
  - `rslb_user.b53_vfca`
  - `rslb_user.b54_isco`
  - `rslb_user.b63_neets_full`
- Access to the microdata application at https://geo-api.aegean.gr/microdata-app/

## Before Running

Four things must be in place before running the pipeline. Complete them in the
following order.

### 0. Reslab database credentials

Several R scripts query the Reslab PostgreSQL database directly. Create the
file `data_prep/env` (it is gitignored) with the connection details:

```
PGHOST=<host>
PGPORT=<port>
PGDATABASE=<database>
PGUSER=<username>
PGPASSWORD=<password>
```

This file is loaded automatically by the R scripts at runtime.

### 1. INSETE data

Download the 13 regional Excel files (one per Greek region) from
https://insete.gr/districts/?lang=en and place them in `data_prep/INSETE/`,
replacing the existing files.

### 2. ELSTAT data

Download the two latest `SBR03` Excel files from
https://www.statistics.gr/el/statistics/-/publication/SBR03/- and place them in
`data_prep/ELSTAT/`, renamed as:

```
SBR03_01.xlsx
SBR03_02.xlsx
```

> If ELSTAT has changed the file format, `data_prep/ELSTAT/data_ELSTAT_preprocess.py` may need adjustments.

### 3. Microdata

Go to https://geo-api.aegean.gr/microdata-app/ and navigate to the **Overview**
tab. Download two separate exports using the *Get data for multiple countries
and years* section:

**Export 1 — Full-time/Part-time employment:**
- Group by: `REGION_2D`, `FTPT`, `FTPTREAS`
- Target variable: `AGE_GRP`
- Save the downloaded file as:
  `data_prep/microdata/microdata__Multi_Years_Country_Group_REGION_2D-FTPT-FTPTREAS__Target_AGE_GRP.csv`

**Export 2 — Permanent/Temporary employment:**
- Group by: `REGION_2D`, `TEMP`, `TEMPREAS`
- Target variable: `AGE_GRP`
- Save the downloaded file as:
  `data_prep/microdata/microdata__Multi_Years_Country_Group_REGION_2D-TEMP-TEMPREAS__Target_AGE_GRP.csv`

## Running the Pipeline

Once all of the above is in place, run:

```bash
./run_all.sh
```

The script will back up any existing `skillscapes.sqlite`, process all data
sources, and produce an updated `skillscapes.sqlite` in the repository root.
