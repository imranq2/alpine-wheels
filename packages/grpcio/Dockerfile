ARG PYTHON_VERSION=3.12
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS builder

# Install common tools and dependencies
RUN apt-get update && apt-get install -y \
    git build-essential python3-dev libffi-dev libssl-dev gcc g++ make \
    && rm -rf /var/lib/apt/lists/*

# Update pip
RUN pip install --upgrade pip

# Install repairwheel
RUN pip install repairwheel

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /tmp/wheels_temp

# https://github.com/jvolkman/repairwheel
RUN repairwheel /tmp/wheels_temp/*.whl -o /wheels

RUN ls -l /wheels


FROM alpine:3.20.3

COPY --from=builder /wheels /wheels
