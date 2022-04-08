FROM python:3.9.12-slim-buster AS build

COPY . /app

RUN python3 -m pip install -r app/requirements.txt

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
