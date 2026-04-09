## Context

The vx project is a greenfield Haskell CLI tool. Before any feature work can happen, we need a fully wired project scaffold: build system, Nix integration, test infrastructure, and coverage enforcement. The user is learning Haskell, so the setup should be idiomatic and approachable.

## Goals / Non-Goals

**Goals:**
- Working `nix develop` with GHC 9.8, cabal, HLS, ormolu, hlint
- Working `nix build` that produces a `vx` binary
- Working `cabal test` with hspec-discover and HPC coverage reporting
- Compiling stub modules for the four core concerns (Parse, Api, Resolve, Exec)
- Test stubs that run and report pending

**Non-Goals:**
- Implementing any actual vx functionality (that's future changes)
- CI/CD pipeline setup
- Publishing to any package registry
- Supporting multiple GHC versions

## Decisions

### Cabal over Stack
Cabal integrates cleanly with Nix flakes — no competing resolver/lockfile. Stack's `stack.yaml` would duplicate what Nix already provides. Cabal is also what `callCabal2nix` expects.

### nixpkgs `haskellPackages` over `haskell.nix`
For a small CLI tool, `callCabal2nix` from nixpkgs is simple and sufficient. `haskell.nix` (IOHK) offers per-component builds and richer CI features but adds significant complexity. We can migrate later if needed.

### GHC 9.8
Current stable in nixpkgs with good library support. Available as `haskell.packages.ghc98` in nixpkgs.

### Hspec over Tasty/HUnit
Hspec provides BDD-style tests (`describe`/`it`), auto-discovery via `hspec-discover`, and bundles HUnit assertions + QuickCheck. The readable test output helps when learning. Auto-discovery means adding a new `*Spec.hs` file automatically includes it in the suite.

### Ormolu for formatting
Zero-config, opinionated formatter. No `.ormolu` file to maintain. Reduces decision fatigue while learning Haskell style.

### Library + Executable + Test-suite split
The `.cabal` file defines three components:
- **library** (`src/`): All logic in `Vx.*` modules — testable in isolation
- **executable** (`src/Main.hs`): Thin entry point that calls library code
- **test-suite** (`test/`): Hspec tests importing the library

This is standard Haskell practice and ensures tests can import all internal modules without circular dependencies.

### Coverage via HPC
GHC's built-in HPC (Haskell Program Coverage) is the standard tool. `cabal test --enable-coverage` generates `.tix` files, `hpc report` produces the summary. The flake wires a coverage check that fails below 95%.

## Risks / Trade-offs

- **[GHC 9.8 library compatibility]** → Some packages may lag behind GHC 9.8. Mitigation: all chosen dependencies (aeson, http-client, optparse-applicative, hspec) have 9.8 support in nixpkgs.
- **[callCabal2nix rebuild granularity]** → Any source change rebuilds the entire package. Mitigation: acceptable for a small project; migrate to `haskell.nix` if build times become painful.
- **[95% coverage on stubs]** → Initial stubs have trivial coverage. Mitigation: the 95% target applies to the final product, not the scaffold. The scaffold just proves the coverage tooling works end-to-end.
