## Why

Every `vx` invocation makes a fresh HTTP request to the Nixhub API, even for the same package+version that was resolved seconds ago. Resolved versions are immutable (a specific version always maps to the same nixpkgs commit), so re-fetching is pure waste. This adds latency, creates a hard dependency on API availability, and is unnecessary for repeat usage.

**Task**: [verynix-9chb — caching of api data](.beans/verynix-9chb--caching-of-api-data.md)

## What Changes

- Add `Vx.Cache` module: file-based JSON cache in `~/.cache/vx/`
- One JSON file per package+system (e.g. `hugo-x86_64-linux.json`) accumulating resolved versions
- Cache `resolveVersion` results permanently (immutable data)
- Cache `fetchVersions` results with lazy invalidation (re-fetch only on cache miss)
- Wire caching into the Main.hs pipeline between parse and API calls
- Add `--no-cache` flag to bypass cache reads (still writes on fresh fetch)
- Add `directory` and `time` dependencies to `vx.cabal`

## Capabilities

### New Capabilities
- `cache`: File-based JSON cache storing resolved versions and version lists per package+system

### Modified Capabilities
- `api-client`: `resolveVersion` and `fetchVersions` gain cache-aware wrappers
- `cli-pipeline`: Main.hs gains `--no-cache` flag handling and cache integration

## Impact

- New file: `src/Vx/Cache.hs`
- Modified files: `app/Main.hs`, `src/Vx/Api.hs`, `vx.cabal`
- New test file: `test/Vx/CacheSpec.hs`
- New dependencies: `directory`, `time` (both GHC boot libraries)
- Cache location: `~/.cache/vx/` (XDG default)
