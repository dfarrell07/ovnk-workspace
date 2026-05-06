#!/usr/bin/env bash
# Clone missing repos and regenerate .gitignore from repos.txt

set -euo pipefail

source "$(dirname "$0")/lib.sh"

# Clone missing repos
"${WORKSPACE_DIR}/scripts/clone-all.sh"

# Regenerate .gitignore
gitignore="${WORKSPACE_DIR}/.gitignore"
{
    echo "# Auto-generated from repos.txt — run 'make sync' to regenerate"
    echo "# Org directories containing cloned sub-repos (tracked independently)"
    while read -r _ _ path; do
        if [[ "$path" == "${WORKSPACE_DIR}/"* ]]; then
            local_rel="${path#"${WORKSPACE_DIR}"/}"
            echo "${local_rel%%/*}/"
        fi
    done < <(read_repos) | sort -u
} > "$gitignore"

echo ""
echo "Regenerated ${gitignore}"
