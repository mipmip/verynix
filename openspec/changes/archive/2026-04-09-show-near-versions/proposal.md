## Why

When a user requests a version that doesn't exist, vx currently prints `resolve failed: API returned status 404`. This is unhelpful — the user has no idea what versions are available or how close they were. Showing the nearest available versions turns a dead end into a useful nudge.

**Task**: [verynix-bu4v — show near versions when not existing](.beans/verynix-bu4v--show-near-versions-when-not-existing.md)

## What Changes

- On a 404 from `/v2/resolve`, make a second call to `/v2/pkg?name=<pkg>` to fetch available versions
- Find the nearest version below and above the requested version (semver ordering)
- Display a helpful message with the neighbors
- Handle edge cases: package not found, version at boundary of available range

## Capabilities

### New Capabilities
- `version-listing`: Fetch and parse the list of available versions for a package from the Nixhub API
- `version-suggestions`: Pure logic to find nearest versions given a target and a sorted list, using semver comparison

### Modified Capabilities
- `cli-pipeline`: Enhanced error path — on version-not-found, fetch neighbors and display suggestion
- `api-client`: Add `fetchVersions` function and version list parsing

## Impact

- New files: `src/Vx/Suggest.hs`, `test/Vx/SuggestSpec.hs`
- Modified files: `src/Vx/Api.hs`, `app/Main.hs`, `vx.cabal`, `test/Vx/ApiSpec.hs`
- New test files: `test/Vx/SuggestSpec.hs`
- No new external dependencies (semver comparison implemented with simple parsing)
