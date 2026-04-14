## Context

vx currently requires `<package>-<version>` format. Users who just want the latest version need to know the exact version number. The Nixhub API supports `version=latest` natively in the `/v2/resolve` endpoint, returning the same response structure as a pinned version.

## Goals / Non-Goals

**Goals:**
- `vx hugo serve` runs the latest version of hugo
- `vx hugo-latest serve` does the same
- Both skip cache (latest is a moving target)
- Verbose mode shows the resolved version number
- Existing `vx hugo-0.147.9 serve` behavior unchanged

**Non-Goals:**
- Version ranges or constraints (e.g., `hugo-~0.147`)
- Caching "latest" with TTL
- Resolving "latest" client-side via `/v2/pkg`

## Decisions

### Maybe Text for version in PackageSpec
Change `packageVersion :: Text` to `packageVersion :: Maybe Text`. `Nothing` means "latest", `Just "latest"` is normalized to `Nothing`, `Just "0.147.9"` is a pinned version. This is the cleanest typed approach — the type system encodes the distinction.

### Nixhub API `version=latest` directly
The resolve endpoint accepts `version=latest` and returns the actual latest version. No need for a two-step flow (fetch versions then resolve). We pass `"latest"` as the version string to the existing `resolveVersion` function when `packageVersion` is `Nothing`.

### Parse changes
Current parser requires `<name>-<version>` where version starts with a digit. New behavior:

| Input | Parsed as |
|---|---|
| `hugo-0.147.9` | `PackageSpec "hugo" (Just "0.147.9")` |
| `hugo-latest` | `PackageSpec "hugo" Nothing` |
| `hugo` | `PackageSpec "hugo" Nothing` |

The parser needs to handle input with no hyphen (name only) and the literal string "latest" as a version.

### Skip cache for latest
When version is `Nothing` (latest), bypass the cache entirely — both read and write. Latest changes over time, so a cached "latest" would go stale. Users wanting speed should pin a version.

### Verbose output for latest
```
resolving hugo (latest) for x86_64-linux...
GET https://search.devbox.sh/v2/resolve?name=hugo&version=latest
resolved: github:NixOS/nixpkgs/<rev>#hugo
exec: nix run github:NixOS/nixpkgs/<rev>#hugo -- serve
```

### Help text update
The optparse metavar changes from `<package>-<version>` to `<package>[-<version>]` to indicate version is optional.

## Risks / Trade-offs

- **[Latest is non-reproducible]** → Two runs of `vx hugo serve` on different days may run different versions. This is by design — users who want reproducibility should pin a version.
- **[No cache for latest]** → Every `vx hugo serve` hits the API. Acceptable since it's a single lightweight HTTP call.
