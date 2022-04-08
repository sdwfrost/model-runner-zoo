FROM r-base:4.1.3 AS build

COPY . /app

# Dependencies for R packages

RUN apt-get update && apt-get -yq dist-upgrade\
    && apt-get install -yq \
    build-essential \
    curl \
    libcurl4-openssl-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libssl-dev \
    libudunits2-dev \
    libv8-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN Rscript --vanilla app/install.R

####################################################################
# Do this here so that we don't have to run the tests when building a release.
FROM build AS release

ENTRYPOINT ["/app/bin/run-model", "/data/input/input.json", "/data/output/data.json", "/data/schema/input.json", "/data/schema/output.json"]

####################################################################
FROM build AS test
# No tests yet.

####################################################################
# Use release as the default
FROM release
