#!/bin/bash
set -e

# Try org endpoint first, fall back to user endpoint — handles both org and personal accounts
fetch_versions() {
    local endpoint="$1"
    curl -s \
        -H "Authorization: Bearer ${GITHUB_PKGS_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        "${endpoint}?per_page=1"
}

ORG_URL="https://api.github.com/orgs/databasus/packages/container/charts%2Fdatabasus/versions"
USER_URL="https://api.github.com/users/databasus/packages/container/charts%2Fdatabasus/versions"

API_RESPONSE=$(fetch_versions "${ORG_URL}")

if echo "${API_RESPONSE}" | jq -e '.message' >/dev/null 2>&1; then
    echo "Org endpoint failed: $(echo "${API_RESPONSE}" | jq -r '.message') — trying user endpoint..." >&2
    API_RESPONSE=$(fetch_versions "${USER_URL}")
fi

UPSTREAM_VERSION=$(echo "${API_RESPONSE}" \
    | jq -r '.[0].metadata.container.tags[] | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))' \
    | head -1)

if [ -z "${UPSTREAM_VERSION}" ]; then
    echo "ERROR: Could not determine upstream version. API response:" >&2
    echo "${API_RESPONSE}" >&2
    exit 1
fi
echo "${UPSTREAM_VERSION}"
