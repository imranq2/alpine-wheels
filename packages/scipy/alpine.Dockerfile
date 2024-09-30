ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}


# Install common tools and dependencies
RUN apk add --no-cache build-base make musl-dev gfortran openblas-dev lapack-dev cython py3-pip py3-setuptools py3-wheel linux-headers

# Set environment variables for OpenBLAS
ENV BLAS=/usr/lib/libopenblas.so
ENV LAPACK=/usr/lib/libopenblas.so


# Build wheels for the specified version of Scipy
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w dist_wheels/

RUN ls -haltR dist_wheels/

RUN apk add --no-cache patchelf

RUN pip install auditwheel

RUN for whl in dist_wheels/*.whl; do auditwheel show "${whl}"; done

RUN for whl in dist_wheels/*.whl; do auditwheel repair "${whl}" --wheel-dir wheels/; done

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
