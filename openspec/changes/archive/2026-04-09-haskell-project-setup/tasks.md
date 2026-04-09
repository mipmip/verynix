## 1. Nix Flake

- [x] 1.1 Create `flake.nix` with `devShells.default` providing GHC 9.8, cabal-install, haskell-language-server, ormolu, and hlint
- [x] 1.2 Add `packages.default` using `callCabal2nix` to build the `vx` executable
- [x] 1.3 Add a coverage output/check that runs tests with HPC enabled and enforces 95% minimum

## 2. Cabal Project

- [x] 2.1 Create `vx.cabal` with library component exposing `Vx.Parse`, `Vx.Api`, `Vx.Resolve`, `Vx.Exec`
- [x] 2.2 Add executable component `vx` with `Main.hs` entry point, depending on the library
- [x] 2.3 Add test-suite component `vx-test` using `hspec-discover` with `test/Spec.hs` as entry point
- [x] 2.4 Declare all dependencies: optparse-applicative, aeson, http-client, http-client-tls, typed-process, hspec, hspec-discover, QuickCheck

## 3. Source Modules

- [x] 3.1 Create `src/Main.hs` — entry point that prints stub message
- [x] 3.2 Create `src/Vx/Parse.hs` — stub module with placeholder types and functions for arg parsing
- [x] 3.3 Create `src/Vx/Api.hs` — stub module with placeholder types and functions for Nixhub API client
- [x] 3.4 Create `src/Vx/Resolve.hs` — stub module with placeholder types and functions for version resolution
- [x] 3.5 Create `src/Vx/Exec.hs` — stub module with placeholder types and functions for nix run execution

## 4. Test Modules

- [x] 4.1 Create `test/Spec.hs` with hspec-discover pragma
- [x] 4.2 Create `test/Vx/ParseSpec.hs` with at least one pending test
- [x] 4.3 Create `test/Vx/ApiSpec.hs` with at least one pending test
- [x] 4.4 Create `test/Vx/ResolveSpec.hs` with at least one pending test
- [x] 4.5 Create `test/Vx/ExecSpec.hs` with at least one pending test

## 5. Verification

- [ ] 5.1 Verify `nix develop` provides ghc, cabal, hls, ormolu, hlint
- [ ] 5.2 Verify `cabal build` compiles all components
- [ ] 5.3 Verify `cabal test` runs hspec suite and shows all spec modules
- [ ] 5.4 Verify `nix build` produces `./result/bin/vx`
- [ ] 5.5 Verify coverage tooling runs and produces an HPC report
