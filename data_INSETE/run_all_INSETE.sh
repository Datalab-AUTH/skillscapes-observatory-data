#!/bin/sh
#
# This script launches all respective preprocessing and generates their
# corresponding csv files.

docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp \
	python-skillscapes \
	/bin/sh -c 'python data_INSETE_hotels_preprocess.py && \
		python data_INSETE_short_stay_preprocess.py && \
		python data_INSETE_employment.py && \
		python data_INSETE_key_figures_preprocess.py && \
		python data_INSETE_STR_preprocess.py'
