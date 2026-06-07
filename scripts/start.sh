#!/bin/bash
set -e
echo "Starting build workflow"

scripts/prepare.sh
scripts/docker_initialize.sh

export DATESTAMP=$(date +%Y%m%d)

echo "Fetching latest version from Docker Hub (databasus/databasus)..."
VERSION=$(scripts/get_upstream_version.sh)
export VERSION
echo "Upstream version: ${VERSION}"

LATEST_BUILT=$(cat latest_version.txt 2>/dev/null | tr -d '[:space:]' || true)
if [ -n "${LATEST_BUILT}" ]; then
    NEWEST=$(printf '%s\n%s' "${LATEST_BUILT}" "${VERSION}" | sort -V | tail -1)
    if [ "${NEWEST}" = "${LATEST_BUILT}" ]; then
        echo "Upstream ${VERSION} is not newer than built ${LATEST_BUILT}, nothing to do."
        exit 0
    fi
fi

export BASE_IMAGE="databasus/databasus:v${VERSION}"
#scripts/docker_build.sh

scripts/commit_version.sh

scripts/docker_cleanup.sh
