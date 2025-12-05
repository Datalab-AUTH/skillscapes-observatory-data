#!/usr/bin/Rscript

# The INSETE stuff needs to run first in order to generate data for the
# gen_nuts.R script.

source('gr_INSETE.R')

# also the Greek population data
source('gr_population.R')
# and the land area data
source('gr_land_area.R')

# ELSTAT data for tourism turnover
source('gr_ELSTAT.R')

# now go on with the rest of the data from eurostat and reslab
source('gen_population.R')
source('gen_land_area.R')
source('gen_nuts.R')

source('eu_economy_gdp.R')
source('eu_economy_gfcf.R')
source('eu_economy_gva.R')

source('eu_labour_employ_labour_force.R')
source('eu_labour_employ_total_employment.R')
source('eu_labour_employ_unemployment.R')

source('eu_labour_employ_youth_employment.R')
source('eu_labour_employ_youth_employment_rate.R')
source('eu_labour_employ_youth_unemployment.R')
source('eu_labour_employ_youth_unemployment_rate.R')
source('eu_labour_employ_youth_long_term_unemployment_rate.R')


source('eu_labour_employ_total_employment_rate.R')
source('eu_labour_employ_unemployment_rate.R')
source('eu_labour_employ_part_full_time_employment.R')

source('eu_labour_employ_weekly_hours.R')


source('eu_labour_employ_employees.R')

source('eu_labour_sector_employment.R')

source('eu_labour_skill_skills.R')
source('eu_labour_skill_youth_skills.R')
source('eu_labour_skill_employment_rates.R')

source('eu_labour_precarity_neets.R')
source('eu_labour_precarity_vfca.R')
source('eu_labour_precarity_housing.R')
source('eu_labour_precarity_persons_low_work.R')
source('eu_labour_precarity_persons_risk_poverty.R')
source('eu_labour_precarity_deprivation.R')

source('eu_tourism_eu_nights_spent.R')
source('eu_tourism_eu_bed_places.R')
source('eu_tourism_eu_short_stay.R')
source('eu_tourism_eu_gfcf.R')
source('eu_tourism_eu_arrivals.R')

