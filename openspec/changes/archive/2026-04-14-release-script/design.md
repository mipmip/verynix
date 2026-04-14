## Context

The vx project needs a repeatable release process. Currently at version 0.1.0.0 (PVP), no changelog, no tags, no GitHub releases. This change establishes the full flow from changelog maintenance through release creation.

## Goals / Non-Goals

**Goals:**
- One-command interactive release: `./release.sh`
- SemVer versioning (3-component)
- Keep a Changelog format
- GitHub release with changelog section as release notes
- Convention for adding changelog entries during development

**Non-Goals:**
- CI/CD automation (future proposal)
- Binary distribution / Cachix (future proposal)
- Automated changelog generation from commits

## Decisions

### SemVer over PVP
vx is a CLI tool consumed by Nix users, not a Haskell library. SemVer (major.minor.patch) is the universal standard for end-user software. PVP's 4-component scheme is for Haskell library API compatibility guarantees which don't apply here. Change `0.1.0.0` to `0.1.0` in `vx.cabal`.

### Gum for interactive selection
[Charmbracelet Gum](https://github.com/charmbracelet/gum) provides polished TUI widgets. The release script uses `gum choose` for the bump type dropdown. Gum is available via `nix run nixpkgs#gum` or can be installed system-wide. The script checks for gum availability and suggests the nix command if missing.

### Keep a Changelog format
Following https://keepachangelog.com/ — widely recognized, simple, parseable:

```markdown
# Changelog

## [Unreleased]

## [0.2.0] - 2026-04-14

### Added
- Version suggestions when requested version doesn't exist
```

Categories: Added, Changed, Deprecated, Removed, Fixed, Security.

### Changelog as GitHub release notes
The release script extracts the content between the new version heading and the previous version heading, then passes it to `gh release create --notes`. This means the changelog is the single source of truth for release notes.

### Changelog convention in CLAUDE.md
Add an instruction to CLAUDE.md that when a change is archived, a summary line should be added to the `## [Unreleased]` section of CHANGELOG.md under the appropriate category (Added, Changed, Fixed, etc.). This is a workflow convention, not automation.

### Release script flow

```
./release.sh
    │
    ├─ 1. Read current version from vx.cabal
    │     Parse: version: X.Y.Z
    │
    ├─ 2. gum choose "major" "minor" "patch"
    │     User picks bump type
    │
    ├─ 3. Compute new version
    │     major: X+1.0.0
    │     minor: X.Y+1.0
    │     patch: X.Y.Z+1
    │
    ├─ 4. Confirm with user
    │     gum confirm "Release 0.1.0 → 0.2.0?"
    │
    ├─ 5. Update vx.cabal version field
    │     sed: version: 0.1.0 → version: 0.2.0
    │
    ├─ 6. Update CHANGELOG.md
    │     Replace: ## [Unreleased]
    │     With:    ## [Unreleased]\n\n## [0.2.0] - 2026-04-14
    │
    ├─ 7. git add + git commit -m "release v0.2.0"
    │
    ├─ 8. git tag v0.2.0
    │
    ├─ 9. git push && git push --tags
    │
    └─ 10. gh release create v0.2.0 --title "v0.2.0" --notes "<changelog section>"
```

### Pre-flight checks
The script should verify before starting:
- Working tree is clean (no uncommitted changes)
- On main branch
- `gum` is available
- `gh` is available and authenticated
- `## [Unreleased]` section exists and has content

## Risks / Trade-offs

- **[Gum dependency]** → Not installed by default. Mitigation: script prints a helpful `nix run nixpkgs#gum` suggestion if missing. Could fall back to bash `select` but gum is nicer.
- **[Changelog parsing brittleness]** → Extracting release notes relies on heading format. Mitigation: Keep a Changelog is a well-defined format; sed/awk patterns are straightforward.
- **[Force push risk]** → The script pushes to main. Mitigation: pre-flight check ensures clean tree and main branch. The push is a normal push, not force.
