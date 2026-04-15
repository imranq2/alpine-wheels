ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS builder

# Fix for getting same hash
ARG SOURCE_DATE_EPOCH=1690000000
ARG PYTHONHASHSEED=0
# Set the environment variables based on the passed arguments
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}
ENV PYTHONHASHSEED=${PYTHONHASHSEED}

# Install common tools and dependencies
RUN apt-get update && apt-get install -y \
    git build-essential gcc g++ libffi-dev python3-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install rustup (Rust installer) with verification
RUN curl https://sh.rustup.rs -sSf -o /tmp/rustup-init.sh \
    && sh /tmp/rustup-init.sh -y \
    && rm /tmp/rustup-init.sh

# Ensure rust binaries are in the PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Update pip
RUN pip install --upgrade pip

# Install auditwheel for manylinux wheel repair
RUN pip install auditwheel patchelf

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /tmp/wheels_temp

# Repair wheels for manylinux compatibility
RUN auditwheel repair /tmp/wheels_temp/*.whl -w /wheels

RUN ls -l /wheels


FROM alpine:${ALPINE_VERSION}

COPY --from=builder /wheels /wheels
