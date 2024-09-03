ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}


# Install common tools and dependencies
RUN apk add --no-cache git build-base gcc musl-dev python3-dev libffi-dev crc32c-dev

# Build wheels for the specified version
ARG PACKAGE_VERSION
RUN pip wheel --no-cache-dir google-crc32c==$PACKAGE_VERSION --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
