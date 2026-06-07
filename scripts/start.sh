#!/bin/bash
set -e
echo "Starting build workflow"

scripts/prepare.sh
scripts/docker_initialize.sh

export DATESTAMP=$(date +%Y%m%d)

echo "Fetching latest version from ghcr.io/databasus/charts/databasus..."
VERSION=$(scripts/get_upstream_version.sh)
export VERSION
echo "Upstream version: ${VERSION}"

LATEST_BUILT=$(cat latest_version.txt 2>/dev/null | tr -d '[:space:]' || true)
if [ "${LATEST_BUILT}" = "${VERSION}" ]; then
    echo "Version ${VERSION} already built, nothing to do."
    exit 0
fi

export BASE_IMAGE="databasus/databasus:${VERSION}"
scripts/docker_build.sh

scripts/commit_version.sh

scripts/docker_cleanup.sh
