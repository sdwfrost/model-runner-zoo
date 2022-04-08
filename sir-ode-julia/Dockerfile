FROM julia:1.7.2-buster AS build

COPY . /app

RUN julia app/install.jl

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
