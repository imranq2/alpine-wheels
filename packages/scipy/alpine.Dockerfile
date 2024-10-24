ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20
ARG DEBIAN_VERSION=bookworm
ARG TARGETARCH=aarch64

# Use the appropriate base image based on the TARGETARCH argument
FROM quay.io/pypa/musllinux_1_2_${TARGETARCH} AS builder

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION

# Fix for getting same hash
ARG SOURCE_DATE_EPOCH=1690000000
ARG PYTHONHASHSEED=0

# Set the environment variables based on the passed arguments
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}
ENV PYTHONHASHSEED=${PYTHONHASHSEED}

# Setup environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1
ENV ACCEPT_EULA=Y

# Install necessary packages and dependencies
RUN apk update && apk add --no-cache \
    curl \
    unixodbc-dev \
    bash \
    libffi-dev \
    openssl-dev \
    cargo \
    musl-dev \
    postgresql-dev \
    cmake \
    rust \
    linux-headers \
    libc-dev \
    libgcc \
    libstdc++ \
    ca-certificates \
    zlib-dev \
    bzip2-dev \
    xz-dev \
    lz4-dev \
    zstd-dev \
    snappy-dev \
    brotli-dev \
    build-base \
    autoconf \
    boost-dev \
    flex \
    libxml2-dev \
    libxslt-dev \
    libjpeg-turbo-dev \
    ninja \
    git \
    g++ \
    gcc \
    py-pip \
    python3 \
    python3-dev \
    re2-dev \
    gfortran \
    openblas-dev \
    lapack-dev

# Set environment variables for OpenBLAS
ENV BLAS=/usr/lib/libopenblas.so
ENV LAPACK=/usr/lib/libopenblas.so

# Update pip and install necessary Python packages
RUN python3 -m venv /venv && \
  . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install wheel auditwheel Cython numpy build setuptools setuptools_scm && \
    pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels

RUN ls -l /tmp/wheels

# Show the contents of the wheels using auditwheel
RUN auditwheel show /tmp/wheels/*.whl

# Repair the wheels using auditwheel
RUN auditwheel repair /tmp/wheels/*.whl -w /wheels

# Show the contents of the repaired wheels
RUN auditwheel show /wheels/*.whl

# List the contents of the /wheels directory
RUN ls -l /wheels

# Use a Python Alpine image for testing
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS tester

# Copy the built wheels and test script from the builder stage
COPY --from=builder /wheels /wheels

# Install runtime dependencies required by the application
RUN apk update && apk add --no-cache curl libstdc++ libffi git lz4-dev snappy

# Install the built wheels
RUN pip -vvv install /wheels/*.whl

# Use an Alpine image for the final stage
FROM alpine:3.20.3

# Copy the built wheels and Arrow source code from the builder stage
COPY --from=builder /wheels /wheels

# List the contents of the /wheels directory
RUN ls -l /wheels
