#!/bin/bash
set -e
# Expects env: VERSION, BRANCH_NAME
echo "${VERSION}" > latest_version.txt
echo "Updated latest_version.txt to ${VERSION}"

git config user.email "jenkins@build" || true
git config user.name "Jenkins" || true
git add latest_version.txt
if ! git diff --staged --quiet; then
    git commit -m "[skip ci] Update latest_version.txt to ${VERSION}" \
        && git push origin "${BRANCH_NAME}" \
        || echo "Warning: Could not commit/push latest_version.txt — update it manually if needed"
fi
