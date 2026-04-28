#!/usr/bin/env bash
# Fetch all remotes for every repo in the workspace

set -euo pipefail

source "$(dirname "$0")/lib.sh"

failed=0

while read -r dirname _ path; do
    if [[ ! -d "${path}/.git" ]]; then
        echo "SKIP  ${dirname} (not cloned at ${path})"
        continue
    fi
    if output="$(git -C "$path" fetch --all --prune 2>&1)"; then
        echo "OK    ${dirname}"
    else
        echo "FAIL  ${dirname}"
        echo "$output" | sed 's/^/      /'
        failed=$((failed + 1))
    fi
done < <(read_repos)

if [[ $failed -gt 0 ]]; then
    echo ""
    echo "${failed} repo(s) failed to fetch."
    exit 1
fi
