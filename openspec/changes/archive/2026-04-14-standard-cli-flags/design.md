## Context

The vx CLI currently uses hand-rolled pattern matching for argument parsing. With `--no-cache` already present and three more flags needed (`--help`, `--version`, `--verbose`), it's time to switch to `optparse-applicative` for structured flag handling.

## Goals / Non-Goals

**Goals:**
- `--help` / `-h` with auto-generated usage info
- `--version` / `-V` showing version from `Paths_vx`
- `--verbose` / `-v` showing resolution details (API URL, resolved commit, exec command)
- `--no-cache` migrated to optparse
- Clean Options record for all flags

**Non-Goals:**
- Subcommands (search, versions, resolve) — future work
- Log levels beyond verbose/quiet
- Colored output

## Decisions

### optparse-applicative over hand-rolled parsing
Four flags plus a positional argument with passthrough is the sweet spot for optparse-applicative. It provides auto-generated `--help`, composable parsers, and standard Unix flag conventions. The library was in the original cabal deps and was removed when we kept things minimal — time to bring it back.

### Options record + Command type
```haskell
data Options = Options
  { optVerbose :: Bool
  , optNoCache :: Bool
  , optSpec    :: String
  , optArgs    :: [String]
  }
```

`--version` and `--help` are handled by optparse built-ins (`infoOption` and auto-help), not in the Options record.

### Paths_vx for version
Cabal auto-generates `Paths_vx` module with a `version :: Version` value read from the `.cabal` file at build time. This is the standard Haskell approach — zero maintenance, always in sync. Requires adding `Paths_vx` to `other-modules` in the executable section.

### Verbose logging in Main.hs only
Verbose output is printed in Main.hs before each pipeline step. No changes to library modules — they stay pure/IO without logging concerns. Verbose output goes to stderr so it doesn't interfere with piped stdout.

### Verbose output format
```
resolving hugo 0.147.9 for x86_64-linux...
GET https://search.devbox.sh/v2/resolve?name=hugo&version=0.147.9
resolved: nixpkgs/992f9165...#hugo
exec: nix run github:NixOS/nixpkgs/992f9165...#hugo -- version
```

When cache hits:
```
resolving hugo 0.147.9 for x86_64-linux...
cache hit: nixpkgs/992f9165...#hugo
exec: nix run github:NixOS/nixpkgs/992f9165...#hugo -- version
```

### Passthrough args with --
optparse-applicative can handle `--` separators natively. Arguments after the package spec are passthrough args. `vx --verbose hugo-0.147.9 -- serve --port 8080` works naturally.

## Risks / Trade-offs

- **[optparse-applicative adds complexity]** → Acceptable trade-off for proper `--help`, flag composition, and future subcommand support.
- **[Paths_vx and nix build]** → `callCabal2nix` handles `Paths_vx` correctly. Verified by the existing nix build infrastructure.
