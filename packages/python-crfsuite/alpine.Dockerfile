ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

# Fix for getting same hash
ARG SOURCE_DATE_EPOCH=1690000000
ARG PYTHONHASHSEED=0
# Set the environment variables based on the passed arguments
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}
ENV PYTHONHASHSEED=${PYTHONHASHSEED}

# Install build tools and dependencies required for python-crfsuite
# Install build tools and required dependencies
RUN apk add --no-cache \
    build-base \
    musl-dev \
    python3-dev \
    libffi-dev \
    libtool \
    autoconf \
    automake

# Additional dependency needed for linking C++ code in pycrfsuite
RUN apk add --no-cache libstdc++-dev

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN pip install --verbose --no-binary ${PACKAGE_NAME} ${PACKAGE_NAME}==${PACKAGE_VERSION}
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels