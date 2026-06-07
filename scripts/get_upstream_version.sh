#!/bin/bash
set -e
# GitHub API returns versions sorted newest-first, so .[0] is always the latest release.
# The ghcr.io OCI tags/list endpoint is paginated and alphabetically ordered,
# which causes old versions (e.g. 3.34.x) to appear "latest" on the first page.
UPSTREAM_VERSION=$(curl -sf \
    -H "Authorization: Bearer ${GITHUB_PKGS_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/orgs/databasus/packages/container/charts%2Fdatabasus/versions?per_page=1" \
    | jq -r '.[0].metadata.container.tags[] | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' \
    | head -1)

if [ -z "${UPSTREAM_VERSION}" ]; then
    echo "ERROR: Could not determine upstream version from GitHub Packages API" >&2
    exit 1
fi
echo "${UPSTREAM_VERSION}"
