.PHONY: numpy
numpy:
	cd packages/numpy && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 --build-arg PACKAGE_VERSION=1.26.4 -t my-scipy-builder:latest --output type=local,dest=../../wheels .

.PHONY: scipy
scipy:
	cd packages/scipy && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 --build-arg PACKAGE_VERSION=1.13.1 -t my-scipy-builder:latest --output type=local,dest=../../wheels .
