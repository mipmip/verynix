## Why

The project has no release process. Cutting a release currently means manually editing version numbers, creating tags, and writing release notes. A release script automates this into a single interactive command, and a changelog provides a human-readable history of changes.

**Task**: [verynix-jp9g — release script](.beans/verynix-jp9g--release-script.md)

## What Changes

- Create `CHANGELOG.md` with Keep a Changelog format and an `[Unreleased]` section
- Create `release.sh` shell script that:
  - Shows a gum dropdown to pick major/minor/patch
  - Bumps the version in `vx.cabal`
  - Rewrites the CHANGELOG.md Unreleased section into a dated release heading
  - Commits, tags, pushes, and creates a GitHub release with changelog as notes
- Switch version scheme from PVP 4-component (`0.1.0.0`) to SemVer 3-component (`0.1.0`) in `vx.cabal`
- Add CLAUDE.md instruction for adding changelog entries when archiving changes

## Capabilities

### New Capabilities
- `release-flow`: Interactive shell script to cut a release
- `changelog-format`: CHANGELOG.md file following Keep a Changelog convention

### Modified Capabilities
_None._

## Impact

- New files: `release.sh`, `CHANGELOG.md`
- Modified files: `vx.cabal` (version format change), `CLAUDE.md` (changelog convention)
- New runtime dependency for release script: `gum` (via `nix run nixpkgs#gum` or system)
- No changes to Haskell source code

## Non-Goals

- GitHub workflow for building binaries or caching in Cachix (separate proposal)
