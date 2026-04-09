## Context

When `vx hugo-0.149.1 version` is run and version 0.149.1 doesn't exist, the Nixhub `/v2/resolve` endpoint returns a 404. Currently this surfaces as a raw error. We want to catch the 404, fetch available versions, and suggest the nearest ones.

## Goals / Non-Goals

**Goals:**
- Helpful error message showing nearest lower and upper version
- Correct semver ordering for neighbor finding
- Handle edge cases gracefully (package not found, boundary versions)
- Pure, testable neighbor-finding logic

**Non-Goals:**
- Fuzzy version matching (auto-selecting a close version)
- Caching the version list
- Supporting version ranges or constraints

## Decisions

### Second API call on 404 only
The version list is only fetched when the resolve fails with 404. Happy path remains a single API call. This keeps the common case fast and avoids unnecessary network requests.

### Trust API ordering + verify with semver parse
The Nixhub `/v2/pkg` endpoint returns releases newest-first, which appears to be semver-sorted. However, we parse versions into (major, minor, patch) tuples and sort ourselves for correctness. The parsing is simple — split on dots, parse as integers, fall back to string comparison for non-numeric segments.

### One neighbor each direction
Show exactly one version below and one above the requested version. This is concise and actionable. If the requested version is below all available, only show the nearest above (and vice versa).

### New module Vx.Suggest for pure logic
The neighbor-finding logic lives in `Vx.Suggest`, separate from the API and CLI modules. This keeps it pure and easily testable. The module exposes:
- `findNeighbors :: Text -> [Text] -> (Maybe Text, Maybe Text)` — given a target version and a list of available versions, returns the nearest lower and upper
- `parseVersion :: Text -> [Int]` — parse a version string into comparable components

### Error message format
```
version 0.149.1 of hugo not found

nearest available versions:
  < 0.148.6
  > 0.150.0
```

When only one direction is available:
```
version 0.0.1 of hugo not found

nearest available version:
  > 0.39.1
```

When the package itself doesn't exist (404 on `/v2/pkg` too):
```
package 'hugu' not found
```

### Distinguish 404 from other errors in Api.hs
Currently `resolveVersion` returns `Left "API returned status 404"`. We need to distinguish "version not found" (404) from other errors so Main.hs can decide whether to fetch suggestions. Options:
- Return a richer error type: `data ResolveError = VersionNotFound | ApiError Text`
- Check the status code before converting to `Either`

Using a sum type is cleaner and lets the caller pattern match.

## Risks / Trade-offs

- **[Extra API call on 404]** → Adds latency on the error path (~200-500ms). Acceptable since it's an error path and the user gets much better feedback.
- **[Version parsing edge cases]** → Some packages may have non-standard version strings (e.g., `20240101`, `3.0.0-rc1`). The parser should handle these gracefully by falling back to string comparison.
- **[Large version lists]** → Some packages may have hundreds of versions. We only need to find two neighbors, so this is fine — linear scan is fast enough.
