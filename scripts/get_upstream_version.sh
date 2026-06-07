#!/bin/bash
set -e
# Queries Docker Hub sorted by newest-first, picks the first tag matching v<semver>,
# then strips the "v" prefix so VERSION is e.g. "3.42.0".
UPSTREAM_VERSION=$(curl -sf \
    "https://hub.docker.com/v2/namespaces/databasus/repositories/databasus/tags?page_size=100&ordering=-last_updated" \
    | jq -r '.results[].name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' \
    | head -1 \
    | sed 's/^v//')

if [ -z "${UPSTREAM_VERSION}" ]; then
    echo "ERROR: Could not determine upstream version from Docker Hub" >&2
    exit 1
fi
echo "${UPSTREAM_VERSION}"
