ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}


# Install common tools and dependencies
RUN apk add --no-cache git build-base

RUN echo "https://mirror.leaseweb.com/alpine/edge/community" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add --no-cache build-base python3-dev libffi-dev openssl-dev musl-dev gcc g++ make

# Build wheels for the specified version
ARG PACKAGE_VERSION
RUN pip wheel --verbose --no-cache-dir grpcio==$PACKAGE_VERSION --no-deps -w /wheels

# List the contents of the /wheels directory to verify the build
RUN ls -l /wheels
