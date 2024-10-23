ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}
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
    && pip install --upgrade pip && pip install pipenv cython numpy

ARG ARROW_SHA256=8379554d89f19f2c8db63620721cabade62541f47a4e706dfb0a401f05a713ef
ARG ARROW_BUILD_TYPE=release

ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local \
    ARROW_PARQUET=1 \
    ARROW_ORC=1 \
    PYARROW_PARALLEL=4 \
    ARROW_VERSION=${PACKAGE_VERSION} \
    VERSION=${PACKAGE_VERSION}

RUN mkdir /arrow \
    && git clone --branch apache-arrow-${PACKAGE_VERSION} https://github.com/apache/arrow.git /arrow && \
    cd /arrow && git checkout apache-arrow-${PACKAGE_VERSION}

# https://arrow.apache.org/docs/developers/guide/step_by_step/building.html
# https://arrow.apache.org/docs/developers/cpp/building.html#cpp-building-building
RUN mkdir /arrow/cpp/build

# Create the patch file for re2
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
RUN pip install --upgrade pip && pip install repairwheel wheel auditwheel Cython numpy build setuptools setuptools_scm

ENV SETUPTOOLS_SCM_PRETEND_VERSION=17.0.0

# Build pyarrow wheel
RUN cd /arrow/python && python -m build --wheel

# RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /arrow/python/dist

# RUN mkdir -p /wheels && cp /tmp/wheels_temp/*.whl /wheels/

# https://github.com/jvolkman/repairwheel
RUN repairwheel /arrow/python/dist/*.whl -o /wheels

RUN ls -l /wheels

RUN auditwheel show /wheels/*.whl

COPY ./diagnose_wheel.py /diagnose_wheel.py

# RUN pip install /wheels/*.whl
#
#FROM alpine:3.20.3
#
#COPY --from=builder /wheels /wheels
#
#COPY --from=builder /arrow /arrow
