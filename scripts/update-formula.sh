#!/usr/bin/env bash
# Regenerate the Homebrew formula from the template, filling in the
# version and the sha256 of the freshly-published npm tarball, then
# commit + push the result.
#
# Invoked by the CLI release workflow after `publish-npm` has run, so
# the tarball we curl below is guaranteed to exist.
#
# npm is the canonical distribution artifact for both npm and Homebrew.
# `npm publish --access public` from CI produces a publicly fetchable tarball at
# `https://registry.npmjs.org/@theticketfairy/cli/-/cli-<version>.tgz`.
#
# Usage: scripts/update-formula.sh <binary> <tag> <version>
#   binary  — formula name (e.g. `ticketfairy`)
#   tag     — git tag (e.g. `v0.1.0`); not currently used in the
#             generated formula but accepted for symmetry with the
#             previous signature and for trace-log readability
#   version — bare version (e.g. `0.1.0`); written into Formula/<binary>.rb

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

# Resolve the canonical npm tarball URL via the registry metadata so
# we hash the exact bytes npm itself will hand to Homebrew on
# `brew install`. The `dist.tarball` field is the immutable post-
# publish URL; `dist.shasum` is the SHA-1 npm uses internally —
# Homebrew wants SHA-256, so we re-hash the downloaded blob.
tarball_url="https://registry.npmjs.org/@theticketfairy/cli/-/cli-${version}.tgz"

echo "Fetching $tarball_url"
# The release workflow waits for npm's publish-time malware scan before
# invoking this script. Keep a short retry window here for residual CDN lag.
sha=""
for attempt in 1 2 3 4 5; do
  if sha="$(curl -fsSL "$tarball_url" | shasum -a 256 | awk '{print $1}')"; then
    if [ -n "$sha" ] && [ "$sha" != "" ]; then
      break
    fi
  fi
  echo "fetch attempt $attempt for $tarball_url failed; sleeping 10s" >&2
  sleep 10
  sha=""
done

if [ -z "$sha" ]; then
  echo "error: could not fetch + hash $tarball_url after 5 attempts" >&2
  exit 1
fi

# Regenerate from the template so the placeholder strings are always
# present in the source — every release rebuilds from a known-good
# starting point rather than mutating the previous output in place.
sed \
  -e "s/VERSION_PLACEHOLDER/${version}/g" \
  -e "s/NPM_TARBALL_SHA/${sha}/g" \
  "$template" > "$formula"

# A full workflow rerun may reach the tap after this exact version was already
# committed. Succeed without creating an empty commit in that recovery case.
if git diff --quiet -- "$formula"; then
  echo "$formula is already at ${version} (${sha:0:12}…); nothing to commit."
  exit 0
fi

git config user.name "ticketfairy-bot"
git config user.email "bot@theticketfairy.com"
git add "$formula"
git commit -m "Bump ${binary} to ${version} (npm tarball, sha256 ${sha:0:12}…)"
git push
