ARG PYTHON_VERSION=3.12
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

# Build wheels for the specified version
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir google-crc32c==$PACKAGE_VERSION -w wheels/

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
