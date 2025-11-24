FROM rocker/tidyverse:4.5.1
WORKDIR /app
COPY renv_1.1.5.tar.gz .
RUN R -e "install.packages('renv_1.1.5.tar.gz', repos = NULL, type = 'source')" \
	&& rm -f renv_1.1.5.tar.gz \
	&& R -e "renv::install(c( \
			'DBI@1.2.3', \
			'RPostgres@1.4.8', \
			'RSQLite@2.4.3', \
			'dotenv@1.0.3', \
			'eurostat@4.0.0' \
		), prompt=F)"
