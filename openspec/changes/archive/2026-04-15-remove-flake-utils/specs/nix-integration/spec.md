# nix-integration Specification

## Purpose
Nix flake providing dev shell, package build, and coverage reporting without external flake helper dependencies.

## Requirements
### Requirement: No flake-utils dependency
The flake SHALL NOT depend on `flake-utils` or any other helper flake. System iteration SHALL use native Nix (`nixpkgs.lib.genAttrs`).

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
- **THEN** the binary executes without error

### Requirement: Coverage reporting via flake
The flake SHALL provide a way to build with HPC coverage enabled and report coverage results.

#### Scenario: Coverage report generated
- **WHEN** a developer runs `nix build .#coverage -L`
- **THEN** an HPC coverage report is produced showing per-module and overall coverage percentages
- **AND** an HTML report is generated at `$out/share/hpc/hpc_index.html`

### Requirement: Multi-system support
The flake SHALL produce outputs for x86_64-linux, aarch64-linux, x86_64-darwin, and aarch64-darwin.
