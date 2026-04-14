## Context

vx resolves package versions via the Nixhub API on every invocation. Resolved data (rev + attrPath for a given package+version+system) is immutable — it never changes once published. The version list changes slowly as new versions are added. Caching both eliminates redundant network calls and enables partial offline usage.

## Goals / Non-Goals

**Goals:**
- Zero network calls for previously-resolved package versions
- Version list caching with lazy invalidation (re-fetch on miss, not on timer)
- Simple file-based cache using XDG cache directory
- `--no-cache` flag to bypass cache reads
- Pure cache logic testable without IO

**Non-Goals:**
- Cache size limits or eviction — files are tiny, growth is bounded by packages used
- XDG_CACHE_HOME override support — use `getXdgDirectory` which handles this
- Cache warming or background refresh
- Concurrent access safety — single-user CLI tool

## Decisions

### One JSON file per package+system

Store cache as `~/.cache/vx/<name>-<system>.json`:

```json
{
  "versions": {
    "0.139.0": {
      "rev": "992f9165...",
      "attrPath": "legacyPackages.x86_64-linux.hugo"
    },
    "0.138.0": {
      "rev": "abc12345...",
      "attrPath": "legacyPackages.x86_64-linux.hugo"
    }
  },
  "availableVersions": ["0.139.0", "0.138.0", "0.137.0"],
  "availableVersionsFetchedAt": "2026-04-09T12:00:00Z"
}
```

The file grows as new versions are resolved. This avoids a database dependency and keeps cache files human-readable and inspectable.

### Permanent caching for resolved versions

A resolved version (name+version+system -> rev+attrPath) is immutable in nixpkgs. Once cached, it never needs revalidation. This is the primary performance win — repeat `vx hugo-0.139.0` calls are instant.

### Lazy invalidation for version lists

The `availableVersions` list is only used for "did you mean?" suggestions when a version isn't found. Strategy:

1. User requests version X
2. Check cached `versions` map — if X is there, use it (skip version list entirely)
3. If X is not cached, call `resolveVersion` API
4. If API returns `VersionNotFound`, check cached `availableVersions` for suggestions
5. If no cached `availableVersions`, or if the list doesn't help, fetch fresh from API
6. Update cache with whatever was fetched

This means the version list is only re-fetched when the user asks for something new that isn't found — which is exactly when the list might be stale.

### Cache lookup flow

```
vx hugo-0.139.0
  │
  ├─ read cache file ~/.cache/vx/hugo-x86_64-linux.json
  │
  ├─ version "0.139.0" in cached versions map?
  │    ├─ yes → use cached rev+attrPath, skip all API calls
  │    └─ no  → call resolveVersion API
  │              ├─ success → add to cache versions map, proceed
  │              └─ VersionNotFound
  │                    ├─ cached availableVersions exist?
  │                    │    ├─ yes → suggest from cache
  │                    │    └─ no  → fetch version list from API
  │                    │              ├─ cache the list
  │                    │              └─ suggest from fresh list
  │                    └─ (either way, show suggestions + exit)
  │
  └─ exec nix run
```

### --no-cache flag

`--no-cache` bypasses cache reads but still writes results to cache. This means:
- Fresh API call every time when flag is set
- Results still get cached for future use without the flag
- Useful for debugging or forcing a fresh resolve

Parsed by simple argv inspection before passing remaining args to the existing pipeline.

### Pure cache data types

`Vx.Cache` exposes pure functions for cache manipulation:

```haskell
data PackageCache = PackageCache
  { versions          :: Map Text NixhubResponse
  , availableVersions :: Maybe [Text]
  , availableVersionsFetchedAt :: Maybe UTCTime
  }

emptyCache :: PackageCache
lookupVersion :: Text -> PackageCache -> Maybe NixhubResponse
addVersion :: Text -> NixhubResponse -> PackageCache -> PackageCache
setAvailableVersions :: [Text] -> UTCTime -> PackageCache -> PackageCache

-- IO boundary
readCache :: FilePath -> IO PackageCache
writeCache :: FilePath -> PackageCache -> IO ()
cachePath :: Text -> Text -> IO FilePath
```

Pure lookup/update functions are testable without disk IO.

## Risks / Trade-offs

- **[Stale version list]** → If a new version is published, the cached `availableVersions` won't include it for suggestions. Mitigation: the user will still get correct behavior (API call for resolve), just potentially incomplete suggestions. The list refreshes next time a VersionNotFound triggers a fresh fetch.
- **[Cache corruption]** → Malformed JSON in cache file could cause parse errors. Mitigation: treat parse failure as cache miss, log a warning, and continue with API call.
- **[Disk usage]** → Unbounded cache growth. Mitigation: each file is <1KB typically. A user would need thousands of distinct packages to reach even 1MB. Not worth optimizing.
