FROM public.ecr.aws/docker/library/python:3.12-alpine3.20

# Install common tools and dependencies
RUN apk add --no-cache build-base gfortran openblas-dev lapack-dev

# Set environment variables for OpenBLAS
ENV BLAS=/usr/lib/libopenblas.so
ENV LAPACK=/usr/lib/libopenblas.so


# Build wheels for the specified version of Scipy
ARG PACKAGE_VERSION
RUN pip wheel --no-cache-dir scipy==$PACKAGE_VERSION --no-deps -w /wheels

# Output wheels to the local directory
CMD ["cp", "-r", "/wheels", "/wheels-output"]
