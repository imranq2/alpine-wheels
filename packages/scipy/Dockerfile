ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}


# Install common tools and dependencies
RUN apk add --no-cache gfortran openblas-dev lapack-dev cython py3-pip py3-setuptools py3-wheel g++ linux-headers

# Set environment variables for OpenBLAS
ENV BLAS=/usr/lib/libopenblas.so
ENV LAPACK=/usr/lib/libopenblas.so


# Build wheels for the specified version of Scipy
ARG PACKAGE_VERSION
RUN pip wheel --no-cache-dir scipy==$PACKAGE_VERSION --no-deps -w /wheels --extra-index-url https://alpine-wheels.github.io/index

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
