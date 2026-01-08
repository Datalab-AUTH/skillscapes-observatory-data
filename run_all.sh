#!/bin/bash

cd data_prep

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

# Then we need to run the ELSTAT and population by region stuff
docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp \
	datalabauth/skillscapes-python \
	/bin/sh -c 'cd ELSTAT; \
		python data_ELSTAT_preprocess.py;
		python data_population_preprocess.py;
		python data_land_area_preprocess.py'

# And the full-time/part-time and permanent/temporary employment data
# that we get from Reslab's microdata app (see comment at the top of the
# data-prep/microdata/microdata.py file on how to get those from the
# microdata app's GUI).
docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp \
	datalabauth/skillscapes-python \
	/bin/sh -c 'cd microdata; \
		python microdata.py'

# Now run everything else

docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp \
	datalabauth/skillscapes-r \
	Rscript all.R

