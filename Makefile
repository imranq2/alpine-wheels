.PHONY: numpy
numpy:
	cd packages/numpy && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=numpy --build-arg PACKAGE_VERSION=1.26.4 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=numpy --build-arg PACKAGE_VERSION=1.26.4 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=numpy --build-arg PACKAGE_VERSION=1.26.4 --build-arg PYTHON_VERSION=3.10 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: scipy
scipy:
	cd packages/scipy && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=scipy --build-arg PACKAGE_VERSION=1.13.1 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: shapely
shapely:
	cd packages/shapely && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=shapely --build-arg PACKAGE_VERSION=2.0.6 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=shapely --build-arg PACKAGE_VERSION=2.0.6 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: google-crc32c
google-crc32c:
	cd packages/google-crc32c && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=google-crc32c --build-arg PACKAGE_VERSION=1.5.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=google-crc32c --build-arg PACKAGE_VERSION=1.5.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: grpcio
grpcio:
	cd packages/grpcio && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=grpcio --build-arg PACKAGE_VERSION=1.66.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=grpcio --build-arg PACKAGE_VERSION=1.66.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: pymongo
pymongo:
	cd packages/default && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=pymongo --build-arg PACKAGE_VERSION=4.8.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=pymongo --build-arg PACKAGE_VERSION=4.8.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: sentence-transformers
sentence-transformers:
	cd packages/default && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=sentence-transformers --build-arg PACKAGE_VERSION=2.7.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=sentence-transformers --build-arg PACKAGE_VERSION=2.7.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: nltk
nltk:
	cd packages/default && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=nltk --build-arg PACKAGE_VERSION=3.9.1 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=nltk --build-arg PACKAGE_VERSION=3.9.1 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: python-crfsuite
python-crfsuite:
	cd packages/python-crfsuite && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=python-crfsuite --build-arg PACKAGE_VERSION=0.9.10 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

#.PHONY: gensim
#gensim:
#	cd packages/default && \
#	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=gensim --build-arg PACKAGE_VERSION=4.3.3 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
#	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=gensim --build-arg PACKAGE_VERSION=4.3.3 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: torch
torch:
	cd packages/torch && \
	docker buildx build --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=torch --build-arg PACKAGE_VERSION=2.4.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels,src=/wheels .

.PHONY: transformers
transformers:
	cd packages/default && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=transformers --build-arg PACKAGE_VERSION=4.45.1 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=transformers --build-arg PACKAGE_VERSION=4.45.1 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: regex
regex:
	cd packages/default && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=regex --build-arg PACKAGE_VERSION=2024.9.11 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=regex --build-arg PACKAGE_VERSION=2024.9.11 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: biotite
biotite:
	cd packages/default && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=biotite --build-arg PACKAGE_VERSION=0.41.2 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=biotite --build-arg PACKAGE_VERSION=0.41.2 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: tiktoken
tiktoken:
	cd packages/tiktoken && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=tiktoken --build-arg PACKAGE_VERSION=0.8.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels . && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=tiktoken --build-arg PACKAGE_VERSION=0.8.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: pyarrow-shell
pyarrow-shell:
	cd packages/pyarrow && \
	docker buildx build --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=pyarrow --build-arg PACKAGE_VERSION=17.0.0 -t alpine-wheel-builder:latest . && \
	docker run -it --rm alpine-wheel-builder:latest sh

.PHONY: pyarrow
pyarrow:
	cd packages/pyarrow && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=pyarrow --build-arg PACKAGE_VERSION=17.0.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: pyarrow-debian
pyarrow-debian:
	cd packages/pyarrow && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=pyarrow --build-arg PACKAGE_VERSION=17.0.0 -t debian-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: pyarrow-debian-shell
pyarrow-debian-shell:
	cd packages/pyarrow && \
	docker buildx build --progress=plain --platform linux/arm64 -f Dockerfile --build-arg PACKAGE_NAME=pyarrow --build-arg PACKAGE_VERSION=17.0.0 -t debian-wheel-builder:latest . && \
	docker run -it --rm debian-wheel-builder:latest sh

.PHONY: playwright
playwright:
	cd packages/playwright && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 -f alpine.Dockerfile --build-arg PACKAGE_NAME=playwright --build-arg PACKAGE_VERSION=1.49.0 --build-arg GITHUB_URL=https://github.com/microsoft/playwright-python.git -t alpine-wheel-builder:latest . && \
	docker run -it --rm alpine-wheel-builder:latest sh
