ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

# Install common tools and dependencies
RUN apk add --no-cache build-base gfortran openblas-dev lapack-dev

# Set environment variables for OpenBLAS
ENV BLAS=/usr/lib/libopenblas.so
ENV LAPACK=/usr/lib/libopenblas.so


# Build wheels for the specified version
ARG PACKAGE_VERSION
RUN pip wheel --no-cache-dir numpy==$PACKAGE_VERSION --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
