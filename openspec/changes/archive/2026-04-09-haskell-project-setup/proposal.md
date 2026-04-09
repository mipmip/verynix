## Why

The vx project needs a working Haskell project scaffold before any feature work can begin. We need a build system, test framework, coverage enforcement, and Nix-based development/distribution — all wired together so that `nix develop`, `cabal build`, `cabal test`, and `nix build` work from day one.

## What Changes

- Add `flake.nix` with dev shell (GHC 9.8, cabal, HLS, ormolu, hlint) and package output
- Add `vx.cabal` with library, executable, and test-suite components
- Create source modules: `Main.hs`, `Vx.Parse`, `Vx.Api`, `Vx.Resolve`, `Vx.Exec`
- Create test modules with hspec-discover: `ParseSpec`, `ApiSpec`, `ResolveSpec`, `ExecSpec`
- Wire up HPC code coverage with a 95% minimum target
- All modules start as compiling stubs with placeholder implementations and pending tests

## Capabilities

### New Capabilities
- `build-system`: Cabal project structure with library/executable/test-suite and all Haskell dependencies
- `nix-integration`: Flake providing dev shell, package build, and coverage reporting
- `test-framework`: Hspec + hspec-discover + QuickCheck test infrastructure with coverage enforcement

### Modified Capabilities

_None — greenfield project._

## Impact

- New files: `flake.nix`, `vx.cabal`, `src/**/*.hs`, `test/**/*.hs`
- New dependencies: GHC 9.8, optparse-applicative, aeson, http-client, http-client-tls, typed-process, hspec, QuickCheck
- After this change: developers can `nix develop` and immediately build, test, and iterate
