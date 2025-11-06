#!/bin/bash

RSCRIPT_CMD="docker run --rm -ti -u `id -u`:`id -g` -v `pwd`:/app -v /tmp:/tmp r-skillscapes Rscript"

if [ -f env ]; then
	for line in env; do
		export $line
	done
fi

${RSCRIPT_CMD} all.R
