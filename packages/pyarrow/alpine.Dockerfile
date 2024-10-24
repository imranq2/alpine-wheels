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
    re2-dev

# Verify GCC installation
RUN gcc --version

# Set Arrow build arguments
ARG ARROW_SHA256=8379554d89f19f2c8db63620721cabade62541f47a4e706dfb0a401f05a713ef
ARG ARROW_BUILD_TYPE=release

# Set environment variables for Arrow
ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local \
    ARROW_PARQUET=1 \
    ARROW_ORC=1 \
    PYARROW_PARALLEL=4 \
    ARROW_VERSION=${PACKAGE_VERSION} \
    VERSION=${PACKAGE_VERSION}

# Download and extract Apache Arrow source code
RUN mkdir /arrow \
    && curl -L https://github.com/apache/arrow/archive/refs/tags/apache-arrow-${PACKAGE_VERSION}.tar.gz -o /arrow/apache-arrow-${PACKAGE_VERSION}.tar.gz \
    && tar -xzf /arrow/apache-arrow-${PACKAGE_VERSION}.tar.gz -C /arrow --strip-components=1

# Create build directory for Arrow
RUN mkdir /arrow/cpp/build

# Set environment variables for CMake
ARG CMAKE_DOWNLOAD_TIMEOUT=3600
ARG APACHE_MIRROR=https://downloads.apache.org

ENV CMAKE_TLS_VERIFY=ON
ENV CMAKE_DOWNLOAD_TIMEOUT=${CMAKE_DOWNLOAD_TIMEOUT}

# Configure the build using CMake
RUN cd /arrow/cpp \
    && cmake -DCMAKE_TLS_VERIFY=ON \
             -DCMAKE_DOWNLOAD_TIMEOUT=${CMAKE_DOWNLOAD_TIMEOUT} \
             --preset ninja-release-python

# Build and install Apache Arrow
RUN cd /arrow/cpp \
    && cmake --build . --target install \
    && rm -rf /tmp/apache-arrow.tar.gz

# Set working directory to Arrow Python bindings
WORKDIR /arrow/python

# List the contents of the /arrow directory
RUN ls -halt /arrow

# Update pip and install necessary Python packages
RUN python3 -m venv /venv && \
  . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install repairwheel wheel auditwheel Cython numpy build setuptools setuptools_scm && \
    cd /arrow/python && \
    python setup.py build_ext --build-type=release --bundle-arrow-cpp bdist_wheel

# Set the version for setuptools_scm
ENV SETUPTOOLS_SCM_PRETEND_VERSION=17.0.0

# List the contents of the /arrow/python/dist directory to verify the build
RUN ls -l /arrow/python/dist

# Copy the built wheels to a temporary directory
RUN mkdir -p /tmp/wheels && cp /arrow/python/dist/*.whl /tmp/wheels/

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
COPY ./test_pyarrow.py /test_pyarrow.py

# Install runtime dependencies required by the application
RUN apk update && apk add --no-cache curl libstdc++ libffi git lz4-dev snappy

# Install the built wheels
RUN pip -vvv install /wheels/*.whl

# Run the test script
RUN python /test_pyarrow.py

# Use an Alpine image for the final stage
FROM alpine:3.20.3

# Copy the built wheels and Arrow source code from the builder stage
COPY --from=builder /wheels /wheels
COPY --from=builder /arrow /arrow

# List the contents of the /wheels directory
RUN ls -l /wheels
