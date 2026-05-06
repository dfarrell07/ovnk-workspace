#!/usr/bin/env bash
# Shared functions for workspace scripts — sourced by other scripts, not executed directly

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_FILE="${WORKSPACE_DIR}/repos.txt"

# Read repos.txt, yielding: org/repo url path
# Org and repo are derived from the URL (https://github.com/ORG/REPO.git).
# An optional second column overrides the repo directory name only.
read_repos() {
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        local url override org repo name path
        url="$(echo "$line" | awk '{print $1}')"
        override="$(echo "$line" | awk '{print $2}')"
        org="$(echo "$url" | sed 's|.*/\([^/]*\)/[^/]*$|\1|')"
        repo="$(echo "$url" | sed 's|.*/||; s|\.git$||')"
        name="${override:-${repo}}"
        path="${WORKSPACE_DIR}/${org}/${name}"
        echo "${org}/${name} ${url} ${path}"
    done < "$REPOS_FILE"
}
