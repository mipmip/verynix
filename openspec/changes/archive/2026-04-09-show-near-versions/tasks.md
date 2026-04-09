## 1. Version Listing (API)

- [x] 1.1 Add `parseVersionList :: ByteString -> Either Text [Text]` pure function to `Vx.Api`
- [x] 1.2 Add `fetchVersions :: Text -> IO (Either Text [Text])` HTTP wrapper to `Vx.Api`
- [x] 1.3 Export new functions from `Vx.Api`
- [x] 1.4 Write mock-based tests for `parseVersionList` in `test/Vx/ApiSpec.hs`

## 2. Resolve Error Type

- [x] 2.1 Add `data ResolveError = VersionNotFound | ApiError Text` to `Vx.Api`
- [x] 2.2 Change `resolveVersion` return type to `IO (Either ResolveError NixhubResponse)`
- [x] 2.3 Return `VersionNotFound` on 404, `ApiError` on other failures
- [x] 2.4 Update existing API tests for new error type

## 3. Version Suggestions (Pure Logic)

- [x] 3.1 Create `src/Vx/Suggest.hs` with `parseVersion`, `findNeighbors`, `formatSuggestion`
- [x] 3.2 Register `Vx.Suggest` in `vx.cabal` exposed-modules
- [x] 3.3 Write tests for `parseVersion` in `test/Vx/SuggestSpec.hs`
- [x] 3.4 Write tests for `findNeighbors` in `test/Vx/SuggestSpec.hs`
- [x] 3.5 Write tests for `formatSuggestion` in `test/Vx/SuggestSpec.hs`

## 4. CLI Pipeline Integration

- [x] 4.1 Update `app/Main.hs` to pattern match on `VersionNotFound` vs `ApiError`
- [x] 4.2 On `VersionNotFound`: call `fetchVersions`, then `findNeighbors`, then `formatSuggestion`, print to stderr
- [x] 4.3 On `ApiError`: print error to stderr as before
- [x] 4.4 Handle `fetchVersions` failure gracefully (fall back to simple "version not found" message)

## 5. Build & Test

- [x] 5.1 Verify `cabal build` compiles
- [x] 5.2 Verify `cabal test` passes
- [x] 5.3 Verify `nix build` produces working binary

## 6. Integration Verification

- [x] 6.1 Run `vx hugo-0.149.1 version` and confirm it shows nearest versions
- [x] 6.2 Run `vx hugo-0.147.9 version` and confirm it still works (happy path)
- [x] 6.3 Run `vx nonexistent-1.0.0 version` and confirm it shows "package not found"
