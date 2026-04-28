#!/usr/bin/env bash
# Clone any repos from repos.txt that aren't already present

set -euo pipefail

source "$(dirname "$0")/lib.sh"

cloned=0
existing=0

while read -r dirname url path; do
    if [[ -d "${path}/.git" ]]; then
        existing=$((existing + 1))
        continue
    fi
    echo "Cloning ${dirname} -> ${path}"
    git clone "$url" "$path"
    cloned=$((cloned + 1))
done < <(read_repos)

echo ""
echo "Cloned: ${cloned}  Already present: ${existing}"
