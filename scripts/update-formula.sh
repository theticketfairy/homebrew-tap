#!/usr/bin/env bash
# Regenerate the Homebrew formula from the template, fill in the per-arch
# sha256 hashes from the freshly-published GitHub Release tarballs, and
# commit + push the result.
#
# Invoked by the release workflow in `theticketfairy/ticketfairy-cli`
# after `pack-tarballs` and `github-release` have run, so the tarballs
# we curl below are guaranteed to exist.
#
# Usage: scripts/update-formula.sh <binary> <tag> <version>
#   binary  — formula name (e.g. `ticketfairy`)
#   tag     — git tag (e.g. `v0.1.0`); used in the release URL
#   version — bare version (e.g. `0.1.0`); written into Formula/<binary>.rb
#
# Run from the repository root.

set -euo pipefail

binary="${1:?formula name (e.g. ticketfairy)}"
tag="${2:?tag (e.g. v0.1.0)}"
version="${3:?version (e.g. 0.1.0)}"

template="Formula/${binary}.rb.template"
formula="Formula/${binary}.rb"

if [ ! -f "$template" ]; then
  echo "error: template $template missing." >&2
  exit 1
fi

fetch_sha() {
  local target="$1"
  curl -fsSL "https://github.com/theticketfairy/ticketfairy-cli/releases/download/${tag}/${binary}-${tag}-${target}.tar.gz" \
    | shasum -a 256 \
    | awk '{print $1}'
}

darwin_arm64_sha="$(fetch_sha darwin-arm64)"
darwin_x64_sha="$(fetch_sha darwin-x64)"
linux_arm64_sha="$(fetch_sha linux-arm64)"
linux_x64_sha="$(fetch_sha linux-x64)"

# Regenerate from the template so the placeholder strings are always
# present in the source — every release rebuilds from a known-good
# starting point rather than mutating the previous output in place.
sed \
  -e "s/VERSION_PLACEHOLDER/${version}/g" \
  -e "s/DARWIN_ARM64_SHA/${darwin_arm64_sha}/g" \
  -e "s/DARWIN_X64_SHA/${darwin_x64_sha}/g" \
  -e "s/LINUX_ARM64_SHA/${linux_arm64_sha}/g" \
  -e "s/LINUX_X64_SHA/${linux_x64_sha}/g" \
  "$template" > "$formula"

git config user.name "ticketfairy-bot"
git config user.email "bot@theticketfairy.com"
git add "$formula"
git commit -m "Bump ${binary} to ${version}"
git push
