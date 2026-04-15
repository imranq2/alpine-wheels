ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20
ARG DEBIAN_VERSION=bookworm
ARG PACKAGE_NAME=torch

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION} AS builder

# Install common tools and dependencies
RUN apt-get update && apt-get install -y \
    git build-essential gcc libffi-dev python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN python3 -m venv /venv && \
  . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install wheel==0.45.1 auditwheel==6.2.0 Cython==3.0.12 numpy==2.2.4 build==1.2.2 setuptools==75.8.2 setuptools_scm==8.2.0 && \
    pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} ${PACKAGE_NAME} --no-deps -w /tmp/wheels

# Conditionally repair wheels (platform wheels get repaired, pure-Python copied as-is)
COPY packages/scripts/repair-wheels.sh /repair-wheels.sh
RUN /repair-wheels.sh /tmp/wheels /built_wheels


FROM alpine:${ALPINE_VERSION}

COPY --from=builder /built_wheels /wheels
