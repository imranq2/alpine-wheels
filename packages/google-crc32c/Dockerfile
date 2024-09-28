ARG PYTHON_VERSION=3.12
ARG DEBIAN_VERSION=bookworm

FROM python:${PYTHON_VERSION}-slim-${DEBIAN_VERSION}

# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION
RUN pip install --verbose --no-binary ${PACKAGE_NAME} ${PACKAGE_NAME}==${PACKAGE_VERSION}
RUN pip wheel --verbose --no-cache-dir ${PACKAGE_NAME}==${PACKAGE_VERSION} --no-binary ${PACKAGE_NAME} --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
