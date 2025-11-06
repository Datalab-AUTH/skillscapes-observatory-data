#!/bin/bash

RSCRIPT_CMD="docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app r-skillscapes Rscript"

if [ -f env ]; then
	source env
fi

${RSCRIPT_CMD} all.R
