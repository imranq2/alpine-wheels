ARG PYTHON_VERSION=3.12
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

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
