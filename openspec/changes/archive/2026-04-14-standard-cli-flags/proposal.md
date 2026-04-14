## Why

The CLI has no `--help`, `--version`, or `--verbose` flags. Users can't discover available options, check which version they're running, or debug resolution issues. The hand-rolled arg parsing is also getting crowded with `--no-cache` already there.

**Task**: [verynix-igzo — standard flags --verbose --help, --version](.beans/verynix-igzo--standard-flags-verbose-help-version.md)

## What Changes

- Add `--help` / `-h` flag (auto-generated usage info)
- Add `--version` / `-V` flag (version from Paths_vx)
- Add `--verbose` / `-v` flag (show resolution details before exec)
- Replace hand-rolled arg parsing with `optparse-applicative`
- Add `Paths_vx` auto-generated module for version embedding
- Add verbose logging in Main.hs showing API URL, resolved commit, and exec command

## Capabilities

### New Capabilities
- `cli-flags`: optparse-applicative based flag parsing with --help, --version, --verbose, --no-cache

### Modified Capabilities
- `cli-pipeline`: Main.hs rewired to use optparse-applicative Options record instead of hand-rolled pattern matching

## Impact

- Modified files: `app/Main.hs`, `vx.cabal`
- New dependency: `optparse-applicative` (re-added to library build-depends)
- Uses `Paths_vx` auto-generated module (cabal feature, no new files)
- No changes to library modules (Vx.Api, Vx.Resolve, etc.)
