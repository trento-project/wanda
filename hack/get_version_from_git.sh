#!/bin/bash
set -euo pipefail

TAG=$( git tag | (grep -E "[0-9]\.[0-9]\.[0-9]" || true) | sort -rn | head -n1 )
COMMIT_SHA=$(git show -s --format=%ct.%h HEAD)

if [ -n "${TAG}" ]; then
  COMMITS_SINCE_TAG=$(git rev-list "${TAG}".. --count)
  if [ "${COMMITS_SINCE_TAG}" -gt 0 ]; then
    SUFFIX="+git.dev${COMMITS_SINCE_TAG}.${COMMIT_SHA}"
  fi
else
  TAG="0.0.0"
  SUFFIX="+git.dev.${COMMIT_SHA}"
fi

echo "${TAG}${SUFFIX}"
