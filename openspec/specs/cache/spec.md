## cache

### Requirements

1. Cache MUST be stored in `~/.cache/vx/` (via `getXdgDirectory XdgCache "vx"`)
2. Cache MUST use one JSON file per package+system, named `<name>-<system>.json`
3. `lookupVersion` MUST return `Just NixhubResponse` when the version exists in the cached `versions` map
4. `lookupVersion` MUST return `Nothing` when the version is not cached
5. `addVersion` MUST add a version entry to the `versions` map without removing existing entries
6. `readCache` MUST return `emptyCache` when the cache file does not exist
7. `readCache` MUST return `emptyCache` when the cache file contains invalid JSON (treat as cache miss)
8. `writeCache` MUST create the cache directory if it does not exist
9. `writeCache` MUST atomically write the cache file (write to temp + rename)
10. `setAvailableVersions` MUST store the version list and the timestamp of when it was fetched
11. `--no-cache` MUST skip cache reads but still write fetched results to cache
12. Cache MUST NOT be used when `--no-cache` is passed as the first argument

### Test Strategy

- Unit test pure functions (`lookupVersion`, `addVersion`, `setAvailableVersions`) with in-memory `PackageCache` values
- Test `readCache` with missing file, empty file, valid JSON, and malformed JSON
- Test `writeCache` + `readCache` roundtrip in a temp directory
- Test `--no-cache` flag parsing in Main.hs
- No network calls in tests
