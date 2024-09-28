ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

# Install common tools and dependencies
RUN apk add --no-cache git build-base musl-dev python3-dev libffi-dev crc32c-dev patchelf make cmake cython


# Set environment variables to force build with C extension
ENV GOOGLE_CRC32C_BUILD_WITH_CYTHON=True
ENV GOOGLE_CRC32C_USE_C_LIB=False
ENV CRC32C_PURE_PYTHON=False

# Build wheels for the specified version
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir google-crc32c==$PACKAGE_VERSION -w dist_wheels/

RUN ls -haltR dist_wheels/

RUN pip install auditwheel

RUN for whl in dist_wheels/*.whl; do auditwheel show "${whl}"; done

RUN for whl in dist_wheels/*.whl; do auditwheel repair "${whl}" --wheel-dir wheels/; done

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels

# Check the package, try and load the native library.
#RUN pip install --no-index --find-links=/wheels google-crc32c==$PACKAGE_VERSION && python -c 'from google_crc32c import _crc32c; print("_crc32c: {}".format(_crc32c)); print("dir(_crc32c): {}".format(dir(_crc32c)))'
