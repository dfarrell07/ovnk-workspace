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
    echo "# Cloned sub-repos (tracked independently)"
    while read -r dirname _ path; do
        # Only ignore repos inside the workspace dir
        if [[ "$path" == "${WORKSPACE_DIR}/"* ]]; then
            echo "${dirname}/"
        fi
    done < <(read_repos)
} > "$gitignore"

echo ""
echo "Regenerated ${gitignore}"
