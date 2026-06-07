#!/bin/bash
set -e
# Fetch all tags (up to 100), filter for v<semver> pattern, sort by version, take highest.
# Sorting ourselves is more reliable than trusting Docker Hub's ordering.
UPSTREAM_VERSION=$(curl -sf \
    "https://hub.docker.com/v2/namespaces/databasus/repositories/databasus/tags?page_size=100&ordering=last_updated" \
    | jq -r '.results[].name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' \
    | sort -V \
    | tail -1 \
    | sed 's/^v//')

if [ -z "${UPSTREAM_VERSION}" ]; then
    echo "ERROR: Could not determine upstream version from Docker Hub" >&2
    exit 1
fi
echo "${UPSTREAM_VERSION}"
