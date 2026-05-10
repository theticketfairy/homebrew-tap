# theticketfairy/homebrew-tap

Homebrew tap for the [Ticket Fairy CLI](https://github.com/theticketfairy/ticketfairy-cli).

```bash
brew install theticketfairy/tap/ticketfairy

ticketfairy --help
```

The formula auto-bumps on every `vX.Y.Z` tag push to the CLI repo via the workflow's `bump-homebrew` job, which calls [`scripts/update-formula.sh`](scripts/update-formula.sh).

## Layout

```
Formula/
├── ticketfairy.rb            # current published formula — what `brew install` reads
└── ticketfairy.rb.template   # source of truth, holds VERSION_PLACEHOLDER / *_SHA tokens
scripts/
└── update-formula.sh         # regenerates ticketfairy.rb from the template each release
```

`Formula/ticketfairy.rb` is regenerated from scratch each release, so the placeholder strings stay intact in the template.

## How updates land

1. CLI repo cuts a `vX.Y.Z` tag → release workflow runs.
2. `pack-tarballs` builds standalone tarballs for `darwin-arm64`, `darwin-x64`, `linux-arm64`, `linux-x64` and uploads them as Release assets.
3. `bump-homebrew` clones this repo with `HOMEBREW_TAP_TOKEN` (a fine-grained PAT with `Contents: write` on this repo only).
4. `scripts/update-formula.sh ticketfairy vX.Y.Z X.Y.Z` regenerates the formula, commits, and pushes — `brew install` immediately picks up the new version.

The token is rotatable: revoking it just means the next release won't auto-bump the formula until a fresh token is in the secret.

## Manual maintenance

You shouldn't need to edit `Formula/ticketfairy.rb` by hand — every release overwrites it. Edit the template if you need to change the formula's structure (e.g. add a new arch, change the install layout). The next release will then propagate that structure with the new version's URLs + hashes filled in.
