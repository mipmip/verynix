## release-flow

### Requirements

1. `release.sh` MUST be an executable shell script at the project root
2. The script MUST read the current version from `vx.cabal`
3. The script MUST present a `gum choose` dropdown with options: major, minor, patch
4. The script MUST compute the new version based on SemVer bump rules
5. The script MUST show the version change and ask for confirmation via `gum confirm`
6. The script MUST update the `version:` field in `vx.cabal`
7. The script MUST replace the `## [Unreleased]` heading in CHANGELOG.md with a dated release heading and add a fresh `## [Unreleased]` section above it
8. The script MUST create a git commit with message `release vX.Y.Z`
9. The script MUST create a git tag `vX.Y.Z`
10. The script MUST push the commit and tag to the remote
11. The script MUST create a GitHub release via `gh release create` with the changelog section as release notes
12. The script MUST perform pre-flight checks before starting: clean working tree, on main branch, gum available, gh available, Unreleased section has content
13. The script MUST exit with a clear error message if any pre-flight check fails
14. The script MUST abort cleanly if the user declines confirmation
