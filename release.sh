#!/bin/bash
# Thin wrapper around fugit's shared release tooling.
# See ./fugit/AGENTS.md ("Add release.sh") for the full contract.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Runs before the changelog commit. fugit stages ONLY CHANGELOG.md, so any
# file this hook mutates MUST be `git add`-ed here or the tag will point at
# the unbumped version. $version_tag is set by fugit before the hook runs.
function release_custom_hook {
    # helm Chart.yaml version is strict SemVer — strip any leading `v`.
    chart_version="${version_tag#v}"
    sed -E -i.bak "s/^version: .*/version: ${chart_version}  # managed by release.sh/" web-app-serve/Chart.yaml
    rm -f web-app-serve/Chart.yaml.bak
    git add web-app-serve/Chart.yaml
}

export -f release_custom_hook
export START_COMMIT=24643d412add65f5394c93757d78144b998c0e2d
export RELEASE_CUSTOM_HOOK=release_custom_hook
export REPO_NAME=toggle-corp/web-app-serve-helm
export DEFAULT_BRANCH=main
# Chart.yaml version is strict SemVer, so tags must NOT carry a `v` prefix.
export VERSION_TAG_PREFIX_MODE=forbid

export GIT_CLIFF__REMOTE__GITHUB__OWNER=toggle-corp
export GIT_CLIFF__REMOTE__GITHUB__REPO=web-app-serve-helm

"$SCRIPT_DIR/fugit/scripts/release.sh" "${@:-}"
