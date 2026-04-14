# Developer Guide

## Prerequisites

- [Nix](https://nixos.org/) with flakes enabled

That's it. Everything else comes from the flake.

## Getting started

Enter the dev shell:

```bash
nix develop
```

This gives you GHC 9.8, cabal, haskell-language-server, ormolu, and hlint.

## Building

```bash
cabal build          # Build all components (library + executable)
cabal run vx         # Build and run the vx binary
cabal list-bin vx    # Show the path to the built binary
```

Build via Nix (produces `./result/bin/vx`):

```bash
nix build
```

## Testing

```bash
cabal test           # Run the hspec test suite
```

Tests use [hspec](https://hspec.github.io/) with auto-discovery. Any file matching `test/Vx/*Spec.hs` is automatically picked up.

## Coverage

```bash
nix build .#coverage -L
```

This builds with HPC coverage enabled, runs tests, and reports coverage for library modules. The build fails if coverage drops below the threshold.

## Code style

**Formatting** with [ormolu](https://github.com/tweag/ormolu) (zero-config):

```bash
ormolu --mode inplace src/**/*.hs test/**/*.hs
```

**Linting** with [hlint](https://github.com/ndmitchell/hlint):

```bash
hlint src/ test/
```

## Project structure

```
app/
  Main.hs              Entry point (executable)

src/
  Vx/
    Api.hs             Nixhub HTTP client
    Cache.hs           Local cache for resolved versions
    Exec.hs            nix run execution (execvp)
    Parse.hs           Argument parsing (package-version syntax)
    Platform.hs        Nix system detection
    Resolve.hs         Version resolution logic, nix run command building
    Suggest.hs         Version suggestion logic (nearest versions)

test/
  Spec.hs              hspec-discover entry point
  Vx/
    *Spec.hs           Tests for each module

flake.nix              Dev shell, package build, coverage build
vx.cabal               Cabal project (library + executable + test-suite)
```

The `.cabal` file defines three components:
- **library** — all `Vx.*` modules, testable in isolation
- **executable** — thin `Main.hs` that calls into the library
- **test-suite** — hspec tests importing the library

## Adding a new module

1. Create the source file at `src/Vx/NewModule.hs`:

    ```haskell
    module Vx.NewModule
      ( -- exports
      ) where
    ```

2. Add it to `exposed-modules` in `vx.cabal`:

    ```cabal
    exposed-modules:
      Vx.Api
      Vx.NewModule   -- add here
      Vx.Parse
      ...
    ```

3. Create the test file at `test/Vx/NewModuleSpec.hs`:

    ```haskell
    module Vx.NewModuleSpec (spec) where

    import Test.Hspec
    import Vx.NewModule

    spec :: Spec
    spec = describe "Vx.NewModule" $ do
      it "does something" $
        pending
    ```

    The test is automatically discovered by hspec — no registration needed.

4. Verify: `cabal build && cabal test`
