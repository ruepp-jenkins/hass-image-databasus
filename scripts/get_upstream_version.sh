#!/bin/bash
set -e
GHCR_TOKEN=$(curl -sf "https://ghcr.io/token?scope=repository:databasus/charts/databasus:pull&service=ghcr.io" | jq -r '.token')
UPSTREAM_VERSION=$(curl -sf -H "Authorization: Bearer ${GHCR_TOKEN}" \
    "https://ghcr.io/v2/databasus/charts/databasus/tags/list" \
    | jq -r '.tags[]' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

if [ -z "${UPSTREAM_VERSION}" ]; then
    echo "ERROR: Could not determine upstream version from ghcr.io" >&2
    exit 1
fi
echo "${UPSTREAM_VERSION}"
