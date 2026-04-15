# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.1] - 2026-04-15

### Changed
- Removed `flake-utils` dependency, using native Nix `genAttrs` instead

### Fixed
- Strict argument ordering: flags after the package spec (e.g., `vx hugo --help`) now pass through to the package instead of being captured by vx

## [0.2.0] - 2026-04-14

### Added
- `--help` / `-h` flag with auto-generated usage info via optparse-applicative
- `--version` / `-V` flag showing version from cabal file
- `--verbose` / `-v` flag showing resolution details (API URL, resolved commit, exec command)
- Latest version support: `vx hugo serve` and `vx hugo-latest serve` resolve and run the latest version

## [0.1.2] - 2026-04-14
- fix release script

## [0.1.1] - 2026-04-14

### Added
- Release script with interactive version bump via gum, changelog management, and GitHub release creation
- CHANGELOG.md following Keep a Changelog format
- SemVer versioning (switched from PVP 4-component)

## [0.1.0] - 2026-04-14

### Added
- Resolve and run any Nix package version: `vx hugo-0.147.9 serve`
- Version resolution via Nixhub API
- Version suggestions when requested version doesn't exist (shows nearest lower and upper)
- Local caching of resolved versions and available version lists
- `--no-cache` flag to bypass cache
- initial start of verynix project
