ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20
ARG DEBIAN_VERSION=bookworm
ARG TARGETARCH=aarch64

# Use the appropriate base image based on the TARGETARCH argument
FROM quay.io/pypa/manylinux_2_28_${TARGETARCH} AS builder
# from https://github.com/pypa/manylinux?tab=readme-ov-file#docker-images

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

# Install common tools and dependencies
RUN dnf -y update && dnf -y install \
    git \
    gcc gcc-c++ make \
    python3-devel \
    cmake \
    wget \
    ninja-build \
    python312 \
    && dnf clean all

# Verify GCC installation
RUN gcc --version

# Update pip and install necessary Python packages
RUN python3.12 -m venv /venv && \
    . /venv/bin/activate && \
    python3.12 -m pip install --upgrade pip && \
    python3.12 -m pip install wheel auditwheel Cython numpy build setuptools setuptools_scm && \
    python3.12 -m pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} ${PACKAGE_NAME} --no-deps -w /tmp/wheels

RUN ls -l /tmp/wheels

# Show the contents of the wheels using auditwheel
# Repair the wheels using auditwheel
RUN for whl in /tmp/wheels/*.whl; do \
        if ! auditwheel show "$whl" 2>&1 | grep -q "platform wheel"; then \
            auditwheel repair "$whl" -w /wheels; \
            auditwheel show /wheels/*.whl; \
        else \
            cp "$whl" /wheels; \
        fi \
    done

# List the contents of the /wheels directory
RUN ls -l /wheels

# Use a Python slim Debian image for testing
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS tester

# Copy the built wheels and test script from the builder stage
COPY --from=builder /wheels /wheels

# Install runtime dependencies required by the application
RUN apt-get update && apt-get install -y \
    curl \
    libstdc++6 \
    libffi-dev \
    git \
    liblz4-dev \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

# Install the built wheels
RUN pip -vvv install /wheels/*.whl

# Use an Alpine image for the final stage
FROM alpine:3.20.3

# Copy the built wheels and Arrow source code from the builder stage
COPY --from=builder /wheels /wheels

# List the contents of the /wheels directory
RUN ls -l /wheels
