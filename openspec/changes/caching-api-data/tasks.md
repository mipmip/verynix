## 1. Cache Module

- [x] 1.1 Create `src/Vx/Cache.hs` with `PackageCache` data type and pure functions (`emptyCache`, `lookupVersion`, `addVersion`, `setAvailableVersions`)
- [x] 1.2 Add JSON serialization (ToJSON/FromJSON) for `PackageCache` and `NixhubResponse`
- [x] 1.3 Implement `readCache` and `writeCache` with atomic writes and graceful corruption handling
- [x] 1.4 Implement `cachePath` using `getXdgDirectory XdgCache "vx"`
- [x] 1.5 Register `Vx.Cache` in `vx.cabal` exposed-modules, add `directory`, `time`, `containers` dependencies

## 2. CLI Integration

- [x] 2.1 Add `--no-cache` flag parsing in `app/Main.hs` (strip from argv before passing to pipeline)
- [x] 2.2 Wire cache into the resolve flow: check cache before API, write to cache after API
- [x] 2.3 Wire cache into the version-not-found flow: check cached `availableVersions` before fetching

## 3. Tests

- [x] 3.1 Write unit tests for pure cache functions in `test/Vx/CacheSpec.hs`
- [x] 3.2 Write IO tests for `readCache`/`writeCache` roundtrip using temp directory
- [x] 3.3 Test cache miss scenarios: missing file, corrupted JSON, missing version entry

## 4. Build & Verify

- [x] 4.1 Verify `cabal build` compiles
- [x] 4.2 Verify `cabal test` passes
- [ ] 4.3 Manual test: run `vx <pkg>-<ver>` twice, confirm second invocation skips API call
- [ ] 4.4 Manual test: run with `--no-cache`, confirm API is called
