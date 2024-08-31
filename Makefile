.PHONY: numpy
numpy:
	cd packages/numpy && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 --build-arg PACKAGE_VERSION=1.26.4 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: scipy
scipy:
	cd packages/scipy && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 --build-arg PACKAGE_VERSION=1.13.1 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: shapely
shapely:
	cd packages/shapely && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 --build-arg PACKAGE_VERSION=2.0.6 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: google-crc32c
google-crc32c:
	cd packages/google-crc32c && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 --build-arg PACKAGE_VERSION=1.5.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .

.PHONY: grpcio
grpcio:
	cd packages/grpcio && \
	docker buildx build --no-cache --progress=plain --platform linux/arm64 --build-arg PACKAGE_VERSION=1.66.0 -t alpine-wheel-builder:latest --output type=local,dest=../../wheels .
