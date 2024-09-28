ARG PYTHON_VERSION=3.12
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

# Install common tools and dependencies
RUN apt-get update && apt-get install -y \
    gfortran libopenblas-dev liblapack-dev cython python3-pip python3-setuptools python3-wheel g++ linux-headers \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for OpenBLAS
ENV BLAS=/usr/lib/libopenblas.so
ENV LAPACK=/usr/lib/libopenblas.so


# Build wheels for the specified version of Scipy
ARG PACKAGE_VERSION
RUN pip install --verbose --no-binary ${PACKAGE_NAME} ${PACKAGE_NAME}==${PACKAGE_VERSION}
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
