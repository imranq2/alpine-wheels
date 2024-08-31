FROM public.ecr.aws/docker/library/python:3.12-alpine3.20

# Install common tools and dependencies
RUN apk add --no-cache git build-base make gcc geos-dev musl-dev

# Build wheels for the specified version of Scipy
ARG PACKAGE_VERSION
RUN pip wheel --no-cache-dir shapely==$PACKAGE_VERSION --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
