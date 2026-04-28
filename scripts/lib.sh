#!/usr/bin/env bash
# Shared functions for workspace scripts — sourced by other scripts, not executed directly

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_FILE="${WORKSPACE_DIR}/repos.txt"

# Read repos.txt, yielding: dirname url path
# Path defaults to ${WORKSPACE_DIR}/${dirname} unless overridden.
read_repos() {
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        local dirname url path
        dirname="$(echo "$line" | awk '{print $1}')"
        url="$(echo "$line" | awk '{print $2}')"
        path="$(echo "$line" | awk '{print $3}')"
        path="${path:-${WORKSPACE_DIR}/${dirname}}"
        # Expand ~ to HOME
        path="${path/#\~/$HOME}"
        echo "${dirname} ${url} ${path}"
    done < "$REPOS_FILE"
}
