## 1. Version Scheme

- [x] 1.1 Change version in `vx.cabal` from `0.1.0.0` to `0.1.0`

## 2. Changelog

- [x] 2.1 Create `CHANGELOG.md` with Keep a Changelog format
- [x] 2.2 Add `[Unreleased]` section (empty, ready for future entries)
- [x] 2.3 Add `[0.1.0]` section documenting initial functionality (resolve + run, version suggestions, caching)

## 3. CLAUDE.md Convention

- [x] 3.1 Add instruction to CLAUDE.md: when archiving a change, add a summary to the `## [Unreleased]` section of CHANGELOG.md

## 4. Release Script

- [x] 4.1 Create `release.sh` with executable permission
- [x] 4.2 Implement pre-flight checks (clean tree, main branch, gum, gh, unreleased content)
- [x] 4.3 Implement version reading from `vx.cabal`
- [x] 4.4 Implement gum choose for bump type selection
- [x] 4.5 Implement SemVer version computation
- [x] 4.6 Implement gum confirm for version change confirmation
- [x] 4.7 Implement vx.cabal version update
- [x] 4.8 Implement CHANGELOG.md heading replacement and new Unreleased section
- [x] 4.9 Implement changelog section extraction for release notes
- [x] 4.10 Implement git commit + tag
- [x] 4.11 Implement git push + gh release create

## 5. Verification

- [x] 5.1 Verify `release.sh` is executable
- [x] 5.2 Verify pre-flight checks catch missing tools and dirty tree
- [x] 5.3 Dry-run: verify version parsing and bump computation work
