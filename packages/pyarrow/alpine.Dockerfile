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
    unzip \
    zip \
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


COPY python_wheel_musllinux_build.sh /arrow/ci/scripts/

ENV VCPKG_FORCE_SYSTEM_BINARIES=1
ENV PYTHON_VERSION=3.12
ARG arch=arm64
ARG arch_short=arm64
ARG musllinux="1-2"

ENV MUSLLINUX_VERSION=${musllinux}

# ARG cmake=3.21.4
#COPY ci/scripts/install_cmake.sh arrow/ci/scripts/
# RUN /arrow/ci/scripts/install_cmake.sh ${arch} linux ${cmake} /usr/local

# Install Ninja
#ARG ninja=1.10.2
#COPY ci/scripts/install_ninja.sh arrow/ci/scripts/
#RUN /arrow/ci/scripts/install_ninja.sh ${ninja} /usr/local

# Install ccache
ARG ccache=4.1
#COPY ci/scripts/install_ccache.sh arrow/ci/scripts/
# RUN /arrow/ci/scripts/install_ccache.sh ${ccache} /usr/local

# Install vcpkg
ARG vcpkg=2024.09.30
#COPY ci/vcpkg/*.patch \
#     ci/vcpkg/*linux*.cmake \
#     arrow/ci/vcpkg/
#COPY ci/scripts/install_vcpkg.sh \
#     arrow/ci/scripts/
ENV VCPKG_ROOT=/opt/vcpkg
ARG build_type=release
ENV CMAKE_BUILD_TYPE=${build_type} \
    VCPKG_FORCE_SYSTEM_BINARIES=1 \
    VCPKG_OVERLAY_TRIPLETS=/arrow/ci/vcpkg \
    VCPKG_DEFAULT_TRIPLET=${arch_short}-linux-static-${build_type} \
    VCPKG_FEATURE_FLAGS="manifests"

# RUN arrow/ci/scripts/install_vcpkg.sh ${VCPKG_ROOT} ${vcpkg}
ENV PATH="${PATH}:${VCPKG_ROOT}"

RUN git clone https://github.com/microsoft/vcpkg.git ${VCPKG_ROOT} && cd ${VCPKG_ROOT} && ./bootstrap-vcpkg.sh

# cannot use the S3 feature here because while aws-sdk-cpp=1.9.160 contains
# ssl related fixes as well as we can patch the vcpkg portfile to support
# arm machines it hits ARROW-15141 where we would need to fall back to 1.8.186
# but we cannot patch those portfiles since vcpkg-tool handles the checkout of
# previous versions => use bundled S3 build
RUN vcpkg install \
        --clean-after-build \
        --x-install-root=${VCPKG_ROOT}/installed \
        --x-manifest-root=/arrow/ci/vcpkg \
        --x-feature=azure \
        --x-feature=flight \
        --x-feature=gcs \
        --x-feature=json \
        --x-feature=parquet \
        --x-feature=s3

# https://arrow.apache.org/docs/developers/guide/step_by_step/building.html
# https://arrow.apache.org/docs/developers/cpp/building.html#cpp-building-building
#RUN mkdir /arrow/cpp/build
#
## Create the patch file for re2
#RUN echo "diff --git a/util/pcre.h b/util/pcre.h" > /arrow/re2_patch.diff \
#    && echo "index e69de29..b6f3e31 100644" >> /arrow/re2_patch.diff \
#    && echo "--- a/util/pcre.h" >> /arrow/re2_patch.diff \
#    && echo "+++ b/util/pcre.h" >> /arrow/re2_patch.diff \
#    && echo "@@ -21,6 +21,7 @@" >> /arrow/re2_patch.diff \
#    && echo " #include \"re2/filtered_re2.h\"" >> /arrow/re2_patch.diff \
#    && echo " #include \"re2/pod_array.h\"" >> /arrow/re2_patch.diff \
#    && echo " #include \"re2/stringpiece.h\"" >> /arrow/re2_patch.diff \
#    && echo "+#include <cstdint>" >> /arrow/re2_patch.diff
#
## ENV CC=musl-gcc
## ENV CXX=musl-g++
#
## Configure the build using CMake
#RUN cd /arrow/cpp \
#    && cmake --preset ninja-release-python
#
## Pre-fetch dependencies without building
#RUN cd /arrow/cpp \
#    && cmake --build . --target re2_ep -- -j1 || true
#
## Apply the patch to re2 after the dependencies are fetched but before the build
#RUN cd /arrow/cpp/re2_ep-prefix/src/re2_ep \
#    && patch -p1 < /arrow/re2_patch.diff
#
## Continue with the build and install Apache Arrow
#RUN cd /arrow/cpp \
#    && cmake --build . --target install \
#    && rm -rf /tmp/apache-arrow.tar.gz
#
#WORKDIR /arrow/python
#
## Create the patch file for re2
#RUN ls -haltR /arrow
#
## Update pip
RUN pip install --upgrade pip && pip install repairwheel wheel auditwheel Cython numpy build setuptools setuptools_scm
#
ENV SETUPTOOLS_SCM_PRETEND_VERSION=17.0.0
#
## Build pyarrow wheel
# RUN chmod +x /arrow/ci/scripts/python_wheel_musllinux_build.sh && /arrow/ci/scripts/python_wheel_musllinux_build.sh
# RUN cd /arrow/python && python -m build --wheel
#
## RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp
#
## List the contents of the /wheels directory to verify the build
# RUN ls -l /arrow/python/dist
#
## RUN mkdir -p /wheels && cp /tmp/wheels_temp/*.whl /wheels/
#
## https://github.com/jvolkman/repairwheel
#RUN repairwheel /arrow/python/dist/*.whl -o /wheels
#
# RUN ls -l /wheels
#
# RUN auditwheel show /wheels/*.whl
#
##
##FROM alpine:3.20.3
##
##COPY --from=builder /wheels /wheels
##
##COPY --from=builder /arrow /arrow
