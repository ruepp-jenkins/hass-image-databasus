#!/bin/bash
set -e
# Expects env: IMAGE_FULLNAME, BRANCH_NAME, VERSION, DATESTAMP, BASE_IMAGE
VERSION_DATESTAMP="${VERSION}-${DATESTAMP}"
echo "[${BRANCH_NAME}] Building ${IMAGE_FULLNAME}:${VERSION} (${VERSION_DATESTAMP}) from ${BASE_IMAGE}"

if [ "$BRANCH_NAME" = "master" ] || [ "$BRANCH_NAME" = "main" ]; then
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --build-arg BUILD_FROM="${BASE_IMAGE}" \
        -t ${IMAGE_FULLNAME}:latest \
        -t ${IMAGE_FULLNAME}:${VERSION} \
        -t ${IMAGE_FULLNAME}:${VERSION_DATESTAMP} \
        --pull \
        --push .
else
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --build-arg BUILD_FROM="${BASE_IMAGE}" \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME} \
        -t ${IMAGE_FULLNAME}:${VERSION} \
        -t ${IMAGE_FULLNAME}:${VERSION_DATESTAMP} \
        --pull \
        --push .
fi
