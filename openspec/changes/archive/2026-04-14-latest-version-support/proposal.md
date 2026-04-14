## Why

Currently vx requires an exact version: `vx hugo-0.147.9 serve`. Users often just want the latest version of a package without looking up version numbers. The Nixhub API natively supports `version=latest` in the resolve endpoint, making this straightforward to implement.

**Tasks**:
- [verynix-twjx — omit version will download latest](.beans/verynix-twjx--omit-version-will-download-latest.md)
- [verynix-xtkz — hugo-latest will download latest](.beans/verynix-xtkz--hugo-latest-will-download-latest.md)

## What Changes

- `vx hugo serve` (omit version) resolves and runs the latest version
- `vx hugo-latest serve` (explicit "latest" keyword) does the same
- Both forms skip the local cache (latest changes over time)
- Verbose mode shows what "latest" resolved to: `latest version: 0.160.1`
- `PackageSpec` changed to use `Maybe Text` for version (Nothing = latest)

## Capabilities

### New Capabilities
_None — this extends existing parsing and pipeline capabilities._

### Modified Capabilities
- `cli-pipeline`: Handle version-less package specs and skip cache for latest
- `cli-flags`: Update usage/help text to reflect optional version

## Impact

- Modified files: `src/Vx/Parse.hs`, `app/Main.hs`, `test/Vx/ParseSpec.hs`
- No new dependencies
- No new modules
- Existing pinned-version behavior unchanged
