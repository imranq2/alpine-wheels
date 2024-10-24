ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20
ARG DEBIAN_VERSION=bookworm

FROM quay.io/pypa/musllinux_1_2_aarch64
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
    python3-dev

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

# Create the patch file for re2
# https://github.com/apache/arrow/issues/43350
RUN echo "diff --git a/util/pcre.h b/util/pcre.h" > /arrow/re2_patch.diff \
    && echo "index e69de29..b6f3e31 100644" >> /arrow/re2_patch.diff \
    && echo "--- a/util/pcre.h" >> /arrow/re2_patch.diff \
    && echo "+++ b/util/pcre.h" >> /arrow/re2_patch.diff \
    && echo "@@ -21,6 +21,7 @@" >> /arrow/re2_patch.diff \
    && echo " #include \"re2/filtered_re2.h\"" >> /arrow/re2_patch.diff \
    && echo " #include \"re2/pod_array.h\"" >> /arrow/re2_patch.diff \
    && echo " #include \"re2/stringpiece.h\"" >> /arrow/re2_patch.diff \
    && echo "+#include <cstdint>" >> /arrow/re2_patch.diff

# Configure the build using CMake
RUN cd /arrow/cpp \
    && cmake --preset ninja-release-python

# Pre-fetch dependencies without building
RUN cd /arrow/cpp \
    && cmake --build . --target re2_ep -- -j1 || true

# Apply the patch to re2 after the dependencies are fetched but before the build
RUN cd /arrow/cpp/re2_ep-prefix/src/re2_ep \
    && patch -p1 < /arrow/re2_patch.diff

# Continue with the build and install Apache Arrow
RUN cd /arrow/cpp \
    && cmake --build . --target install \
    && rm -rf /tmp/apache-arrow.tar.gz

WORKDIR /arrow/python

# Create the patch file for re2
RUN ls -haltR /arrow

# Update pip

# https://arrow.apache.org/docs/developers/python.html#python-development
RUN python3 -m venv /venv && \
  . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install repairwheel wheel auditwheel Cython numpy build setuptools setuptools_scm && \
    cd /arrow/python && \
    python setup.py build_ext --build-type=release --bundle-arrow-cpp bdist_wheel

ENV SETUPTOOLS_SCM_PRETEND_VERSION=17.0.0

# RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /arrow/python/dist

RUN mkdir -p /tmp/wheels && cp /arrow/python/dist/*.whl /tmp/wheels/

# https://github.com/jvolkman/repairwheel
# RUN repairwheel /arrow/python/dist/*.whl -o /wheels

RUN auditwheel show /tmp/wheels/*.whl

RUN auditwheel repair /tmp/wheels/*.whl -w /wheels

RUN auditwheel show /wheels/*.whl

RUN ls -l /wheels
