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
    pip install wheel auditwheel Cython numpy build setuptools setuptools_scm && \
    pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} ${PACKAGE_NAME} --no-deps -w /tmp/wheels && \
    mkdir -p /built_wheels && \
    for whl in /tmp/wheels/*.whl; do \
        echo "Checking wheel $whl" && \
        if ! auditwheel show "$whl" 2>&1 | grep -q "platform wheel"; then \
            echo "Repairing wheel $whl"; \
            auditwheel repair "$whl" -w /built_wheels; \
            auditwheel show /built_wheels/*.whl; \
        else \
            echo "Copying wheel without repair since not a platform wheel $whl"; \
            cp "$whl" /built_wheels/; \
        fi \
    done

# List the contents of the /wheels directory
RUN ls -l /built_wheels


FROM alpine:${ALPINE_VERSION}

COPY --from=builder /built_wheels /wheels
