# nix-integration Specification

## Purpose
TBD - created by archiving change haskell-project-setup. Update Purpose after archive.
## Requirements
### Requirement: Development shell with all tools
The flake SHALL provide a `devShells.default` containing GHC 9.8, cabal-install, haskell-language-server, ormolu, and hlint.

#### Scenario: Enter dev shell
- **WHEN** a developer runs `nix develop`
- **THEN** `ghc --version` reports GHC 9.8.x, and `cabal`, `haskell-language-server`, `ormolu`, and `hlint` are all on `$PATH`

### Requirement: Package build produces vx binary
The flake SHALL provide a `packages.default` that builds the `vx` executable using `callCabal2nix` (or equivalent nixpkgs Haskell infrastructure).

#### Scenario: Build package
- **WHEN** a developer runs `nix build`
- **THEN** `./result/bin/vx` exists and is executable

#### Scenario: Binary runs
- **WHEN** a developer runs `./result/bin/vx`
- **THEN** the binary executes without error (stub output is acceptable)

### Requirement: Coverage reporting via flake
The flake SHALL provide a way to build with HPC coverage enabled and report coverage results.

#### Scenario: Coverage report generated
- **WHEN** a developer runs coverage through the flake (e.g., `nix build .#coverage` or a flake check)
- **THEN** an HPC coverage report is produced showing per-module and overall coverage percentages

