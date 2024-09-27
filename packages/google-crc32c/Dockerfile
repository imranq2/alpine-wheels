ARG PYTHON_VERSION=3.12
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

# Install common tools and dependencies
RUN apt-get update && apt-get install -y \
    git build-essential gcc g++ python3-dev libffi-dev crc32c-dev patchelf make cmake cython \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables to force build with C extension
ENV GOOGLE_CRC32C_BUILD_WITH_CYTHON=True
ENV GOOGLE_CRC32C_USE_C_LIB=False
ENV CRC32C_PURE_PYTHON=False

# Build wheels for the specified version
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir google-crc32c==$PACKAGE_VERSION -w dist_wheels/

RUN ls -haltR dist_wheels/

# Install auditwheel
RUN pip install auditwheel

# Show and repair wheels using auditwheel
RUN for whl in dist_wheels/*.whl; do auditwheel show "${whl}"; done

RUN for whl in dist_wheels/*.whl; do auditwheel repair "${whl}" --wheel-dir wheels/

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
