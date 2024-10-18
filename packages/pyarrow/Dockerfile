ARG PYTHON_VERSION=3.12
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS builder

ARG PACKAGE_NAME
ARG PACKAGE_VERSION

# Fix for getting same hash
ARG SOURCE_DATE_EPOCH=1690000000
ARG PYTHONHASHSEED=0
# Set the environment variables based on the passed arguments
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}
ENV PYTHONHASHSEED=${PYTHONHASHSEED}

# Install common tools and dependencies
RUN apt-get update && apt-get install -y \
    git build-essential python3-dev cmake wget ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Update pip
RUN pip install --upgrade pip

# Install repairwheel
RUN pip install repairwheel

ARG ARROW_SHA256=8379554d89f19f2c8db63620721cabade62541f47a4e706dfb0a401f05a713ef
ARG ARROW_BUILD_TYPE=release

ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local \
    ARROW_PARQUET=1 \
    ARROW_ORC=1 \
    PYARROW_PARALLEL=4

RUN mkdir /arrow \
    && wget -q https://github.com/apache/arrow/archive/apache-arrow-${PACKAGE_VERSION}.tar.gz -O /tmp/apache-arrow.tar.gz \
    && echo "${ARROW_SHA256} *apache-arrow.tar.gz" | sha256sum /tmp/apache-arrow.tar.gz \
    && tar -xvf /tmp/apache-arrow.tar.gz -C /arrow --strip-components 1

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

RUN ls -haltR /arrow

# Update pip
RUN pip install --upgrade pip && pip install repairwheel wheel auditwheel setuptools Cython numpy

# Build pyarrow wheel
RUN cd /arrow/python && python3 setup.py build_ext bdist_wheel --dist-dir /tmp/wheels_temp

# RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /tmp/wheels_temp

RUN mkdir -p /wheels && cp /tmp/wheels_temp/*.whl /wheels/

# https://github.com/jvolkman/repairwheel
# RUN repairwheel /tmp/wheels_temp/*.whl -o /wheels

RUN ls -l /wheels

RUN auditwheel show /wheels/*.whl


FROM alpine:3.20.3

COPY --from=builder /wheels /wheels
