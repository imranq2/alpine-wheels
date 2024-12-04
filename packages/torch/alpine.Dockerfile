ARG PYTHON_VERSION=3.12
ARG ALPINE_VERSION=3.20

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS builder
# Build wheels for the specified version
ARG PACKAGE_NAME
ARG PACKAGE_VERSION

RUN apk add --no-cache git

RUN echo "Building wheels for PyTorch version ${PACKAGE_VERSION}"
RUN git clone --recursive --branch v${PACKAGE_VERSION} https://github.com/pytorch/pytorch

# Install common tools and dependencies
RUN apk add --no-cache gfortran openblas-dev lapack-dev cython py3-pip py3-setuptools py3-wheel linux-headers
RUN apk add --no-cache git cmake make build-base musl-dev python3-dev py3-pip cython
RUN apk add --no-cache openblas-dev lapack-dev
RUN pip install setuptools wheel pyyaml cython typing_extensions
RUN apk add --no-cache gfortran openblas-dev lapack-dev cython py3-pip py3-setuptools py3-wheel linux-headers
RUN #pip install mkl-static mkl-include
RUN apk add --no-cache cmake make build-base musl-dev libffi-dev openssl-dev zlib-dev


# Set environment variables for OpenBLAS
ENV BLAS=OpenBLAS
ENV LAPACK=LAPACK


# Environment variables for PyTorch build
# https://github.com/pytorch/pytorch/blob/main/setup.py
ENV USE_MKLDNN=0
ENV USE_CUDA=0
ENV USE_NNPACK=0
ENV USE_QNNPACK=0
ENV USE_FBGEMM=0
ENV BUILD_TEST=0
ENV CMAKE_PREFIX_PATH="$(python3 -c 'import sys; print(sys.prefix)')"
ENV USE_BLAS=open
ENV _GLIBCXX_USE_CXX11_ABI=1
ENV USE_GLOO=0
ENV SUPPORTS_BACKTRACE=0
ENV USE_TENSORPIPE=0
#ENV BUILD_LIBTORCH_WHL=1
# ENV BUILD_PYTHON_ONLY=1
ENV USE_NUMPY=OFF
ENV BUILD_SHARED_LIBS=ON
ENV NDEBUG=0

# Set environment variables to suppress warnings
ENV CXXFLAGS="-w"
ENV CFLAGS="-w"

# Set environment variables for CMake to locate libraries
ENV C10_LIB="/pytorch/build/lib/libc10.so"
ENV TORCH_CPU_LIB="/pytorch/build/lib/libtorch_cpu.so"
ENV TORCH_LIB="/pytorch/build/lib/libtorch.so"

# Enable shared libs if necessary
#RUN cd pytorch && cmake -DBUILD_SHARED_LIBS=ON .

# Apply patch to c10/macros/Macros.h
# per https://github.com/pytorch/pytorch/issues/55865
RUN sed -i 's/unsigned int line/int line/' pytorch/c10/macros/Macros.h

# RUN cd pytorch && python3 setup.py build

RUN cd pytorch && python3 setup.py bdist_wheel --dist-dir /tmp/wheels_temp

# List the contents of the /wheels directory to verify the build
RUN ls -l /tmp/wheels_temp

RUN pip install repairwheel

# https://github.com/jvolkman/repairwheel
RUN repairwheel /tmp/wheels_temp/*.whl -o /wheels

RUN ls -l /wheels


FROM alpine:${ALPINE_VERSION}

COPY --from=builder /wheels /wheels
