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

# For source code packages
ARG GITHUB_URL

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

# Set working directory
WORKDIR /build

# Clone Playwright repository
# Clone repository using build args
RUN if [ "${PACKAGE_VERSION}" = "latest" ]; then \
        git clone ${GITHUB_URL} ${PACKAGE_NAME}; \
    else \
        git clone --branch v${PACKAGE_VERSION} ${GITHUB_URL} ${PACKAGE_NAME}; \
    fi && \
    cd ${PACKAGE_NAME} && \
    git submodule update --init --recursive

# Move to package directory
WORKDIR /build/${PACKAGE_NAME}

# Update pip and install necessary Python packages
RUN python3 -m venv /venv && \
  . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install wheel auditwheel Cython numpy build setuptools setuptools_scm && \
    python -m build --wheel --outdir /tmp/wheels .

RUN ls -l /tmp/wheels

RUN mkdir -p /built_wheels

# Show the contents of the wheels using auditwheel
# Repair the wheels using auditwheel
RUN for whl in /tmp/wheels/*.whl; do \
        echo "Checking wheel $whl" && \
        if ! auditwheel show "$whl" 2>&1 | grep -q "platform wheel"; then \
            echo "Repairing wheel $whl"; \
            auditwheel repair "$whl" -w /built_wheels; \
            auditwheel show /built_wheels/*.whl; \
        else \
            echo "Copying wheel without repair since not a platform wheel $whl"; \
            cp "$whl" /built_wheels/; \
        fi \
    done

# List the contents of the /wheels directory
RUN ls -l /built_wheels

# Use a Python Alpine image for testing
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS tester

# Copy the built wheels and test script from the builder stage
COPY --from=builder /built_wheels /wheels

# Install runtime dependencies required by the application
RUN apk update && apk add --no-cache curl libstdc++ libffi git lz4-dev snappy

# Install the built wheels
RUN pip -vvv install /wheels/*.whl

# Use an Alpine image for the final stage
FROM alpine:${ALPINE_VERSION}

# Copy the built wheels and Arrow source code from the builder stage
COPY --from=builder /built_wheels /wheels

# List the contents of the /wheels directory
RUN ls -l /wheels
