#!/bin/bash
set -e
# Expects env: VERSION, BRANCH_NAME
echo "${VERSION}" > latest_version.txt
echo "Updated latest_version.txt to ${VERSION}"

git config user.email "jenkins@noreply.ruepp.info"
git config user.name "Jenkins"
git add latest_version.txt

if git diff --staged --quiet; then
    echo "latest_version.txt already contains ${VERSION}, nothing to commit"
else
    git commit -m "[skip ci] Update latest_version.txt to ${VERSION}"
    git push origin "${BRANCH_NAME}"
    echo "Pushed latest_version.txt to origin/${BRANCH_NAME}"
fi
