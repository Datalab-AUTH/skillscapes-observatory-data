#!/bin/bash

#
# All these are for the Eurostat and Aegean DB data
# 

RSCRIPT_CMD="docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp datalabauth/skillscapes-r Rscript"

if [ -f env ]; then
	for line in env; do
		export $line
	done
fi

# First, the INSETE stuff. We'll need the region_codes_EL.csv file this
# generates for the gen_nuts.R file.
# So, preprocess the INSETE excel files to make the respective csv files.
docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp \
	datalabauth/skillscapes-python \
	/bin/sh -c 'cd INSETE; \
		python data_INSETE_hotels_preprocess.py && \
		python data_INSETE_short_stay_preprocess.py && \
		python data_INSETE_employment.py && \
		python data_INSETE_key_figures_preprocess.py && \
		python data_INSETE_hotel_capacity_preprocess.py && \
		python data_INSETE_STR_preprocess.py'

# Now run everything

${RSCRIPT_CMD} all.R

