#!/usr/bin/env bash
set -e

msg() {
    printf "%s.\n" "$*"
}
err() {
    printf "Error: %s.\n" "$*" >&2
    exit 1
}

CURRENT_VERSION="$(cz version --project)"
NEXT_VERSION="${1:-$(cz bump --get-next --yes)}"
MODIFIED_FILES="$(git status --porcelain | awk '!/^\?/')"

if [[ -n "$MODIFIED_FILES" ]]; then
    err "Commit or stash changes before version bump"
fi

cz bump $NEXT_VERSION --version-files-only --changelog --yes
git add --update
git commit -m "bump: version $CURRENT_VERSION → $NEXT_VERSION"
