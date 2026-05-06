#!/usr/bin/env bash
# Fetch + fast-forward pull for repos on the happy path.
# Warns and skips repos that are dirty, on a non-default branch, or can't fast-forward.

set -euo pipefail

source "$(dirname "$0")/lib.sh"

updated=0
skipped=0
failed=0

while read -r name _ path; do
    if [[ ! -d "${path}/.git" ]]; then
        echo "SKIP  ${name} (not cloned)"
        skipped=$((skipped + 1))
        continue
    fi

    if ! output="$(git -C "$path" fetch --all --prune 2>&1)"; then
        echo "FAIL  ${name} (fetch failed)"
        echo "$output" | sed 's/^/      /'
        failed=$((failed + 1))
        continue
    fi

    branch="$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [[ "$branch" != "main" && "$branch" != "master" ]]; then
        echo "SKIP  ${name} (on branch ${branch}, not main/master)"
        skipped=$((skipped + 1))
        continue
    fi

    if [[ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]]; then
        echo "SKIP  ${name} (dirty working tree)"
        skipped=$((skipped + 1))
        continue
    fi

    upstream="$(git -C "$path" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
    if [[ -z "$upstream" ]]; then
        echo "SKIP  ${name} (no upstream tracking branch)"
        skipped=$((skipped + 1))
        continue
    fi

    before="$(git -C "$path" rev-parse HEAD)"
    if output="$(git -C "$path" merge --ff-only '@{upstream}' 2>&1)"; then
        after="$(git -C "$path" rev-parse HEAD)"
        if [[ "$before" == "$after" ]]; then
            echo "OK    ${name} (already up to date)"
        else
            echo "OK    ${name} (updated)"
        fi
        updated=$((updated + 1))
    else
        echo "SKIP  ${name} (can't fast-forward)"
        echo "$output" | sed 's/^/      /'
        skipped=$((skipped + 1))
    fi
done < <(read_repos)

echo ""
echo "Updated: ${updated}  Skipped: ${skipped}  Failed: ${failed}"
[[ $failed -eq 0 ]] || exit 1
