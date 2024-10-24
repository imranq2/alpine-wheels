ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20
ARG DEBIAN_VERSION=bookworm
ARG TARGETARCH=aarch64

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

# Setup env
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
    && dnf clean all

RUN gcc --version

ARG ARROW_SHA256=8379554d89f19f2c8db63620721cabade62541f47a4e706dfb0a401f05a713ef
ARG ARROW_BUILD_TYPE=release

ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local \
    ARROW_PARQUET=1 \
    ARROW_ORC=1 \
    PYARROW_PARALLEL=4 \
    ARROW_VERSION=${PACKAGE_VERSION} \
    VERSION=${PACKAGE_VERSION}

#RUN mkdir /arrow \
#    && git clone --branch apache-arrow-${PACKAGE_VERSION} https://github.com/apache/arrow.git /arrow && \
#    cd /arrow && git checkout apache-arrow-${PACKAGE_VERSION}

RUN mkdir /arrow \
    && curl -L https://github.com/apache/arrow/archive/refs/tags/apache-arrow-${PACKAGE_VERSION}.tar.gz -o /arrow/apache-arrow-${PACKAGE_VERSION}.tar.gz \
    && tar -xzf /arrow/apache-arrow-${PACKAGE_VERSION}.tar.gz -C /arrow --strip-components=1

# https://arrow.apache.org/docs/developers/guide/step_by_step/building.html
# https://arrow.apache.org/docs/developers/cpp/building.html#cpp-building-building
RUN mkdir /arrow/cpp/build

# Configure the build using CMake
RUN cd /arrow/cpp \
    && cmake --preset ninja-release-python

# Continue with the build and install Apache Arrow
RUN cd /arrow/cpp \
    && cmake --build . --target install \
    && rm -rf /tmp/apache-arrow.tar.gz

WORKDIR /arrow/python

# Create the patch file for re2
RUN ls -halt /arrow

# Update pip

# https://arrow.apache.org/docs/developers/python.html#python-development
RUN python3 -m venv /venv && \
  . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install wheel auditwheel Cython numpy build setuptools setuptools_scm && \
    cd /arrow/python && \
    python setup.py build_ext --build-type=release --bundle-arrow-cpp bdist_wheel

ENV SETUPTOOLS_SCM_PRETEND_VERSION=17.0.0

# RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /arrow/python/dist

RUN mkdir -p /tmp/wheels && cp /arrow/python/dist/*.whl /tmp/wheels/

RUN auditwheel show /tmp/wheels/*.whl

RUN auditwheel repair /tmp/wheels/*.whl -w /wheels

RUN auditwheel show /wheels/*.whl

RUN ls -l /wheels

#
FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS tester

COPY --from=builder /wheels /wheels
COPY ./test_pyarrow.py /test_pyarrow.py

# Install runtime dependencies required by the application (e.g., for shapely, grpcio, scipy, google-crc32 and numpy)
# You can use auditwheel to check any package and identify the native library dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libstdc++6 \
    libffi-dev \
    git \
    liblz4-dev \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

# RUN pip -vvv install /wheels/pyarrow-17.0.0-cp312-cp312-musllinux_1_2_aarch64.whl
RUN pip -vvv install /wheels/*.whl

# Run the test script
RUN python /test_pyarrow.py


FROM alpine:3.20.3

COPY --from=builder /wheels /wheels

COPY --from=builder /arrow /arrow

RUN ls -l /wheels
