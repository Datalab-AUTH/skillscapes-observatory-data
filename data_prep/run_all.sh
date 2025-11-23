#!/bin/bash

#
# All these are for the Eurostat and Aegean DB data
# 

RSCRIPT_CMD="docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp r-skillscapes Rscript"

if [ -f env ]; then
	for line in env; do
		export $line
	done
fi

${RSCRIPT_CMD} all.R

#
# Now for the INSETE stuff
#

# First, preprocess the excel files to make the csv files
cd INSETE
docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp \
	python-skillscapes \
	/bin/sh -c 'python data_INSETE_hotels_preprocess.py && \
		python data_INSETE_short_stay_preprocess.py && \
		python data_INSETE_employment.py && \
		python data_INSETE_key_figures_preprocess.py && \
		python data_INSETE_STR_preprocess.py'

cd -

