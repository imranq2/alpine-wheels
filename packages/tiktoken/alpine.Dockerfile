ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS builder

# Fix for getting same hash
ARG SOURCE_DATE_EPOCH=1690000000
ARG PYTHONHASHSEED=0
# Set the environment variables based on the passed arguments
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}
ENV PYTHONHASHSEED=${PYTHONHASHSEED}

# Install common tools and dependencies
RUN apk add --no-cache \
    build-base \
    musl-dev \
    python3-dev \
    libffi-dev \
    libtool \
    autoconf \
    automake \
    curl

# Download and install rustup (Rust installer)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Ensure rust binaries are in the PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels

FROM alpine:3.20.3

COPY --from=builder /wheels /wheels
