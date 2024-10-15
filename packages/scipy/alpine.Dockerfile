ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS builder


# Install common tools and dependencies
RUN apk add --no-cache build-base make musl-dev gfortran openblas-dev lapack-dev cython py3-pip py3-setuptools py3-wheel linux-headers

# Set environment variables for OpenBLAS
ENV BLAS=/usr/lib/libopenblas.so
ENV LAPACK=/usr/lib/libopenblas.so


# Update pip
RUN pip install --upgrade pip

# Install repairwheel
RUN pip install repairwheel

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /tmp/wheels_temp

# https://github.com/jvolkman/repairwheel
RUN repairwheel /tmp/wheels_temp/*.whl -o /wheels

RUN ls -l /wheels


FROM alpine:3.20.3

COPY --from=builder /wheels /wheels
