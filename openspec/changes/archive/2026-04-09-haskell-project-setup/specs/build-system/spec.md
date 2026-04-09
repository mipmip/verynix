## ADDED Requirements

### Requirement: Cabal project with library, executable, and test-suite
The project SHALL define a `vx.cabal` file with three components: a library exposing `Vx.*` modules, an executable `vx` with `Main.hs` as entry point, and a test-suite `vx-test` using hspec-discover.

#### Scenario: Library compiles
- **WHEN** a developer runs `cabal build lib:vx`
- **THEN** the library compiles successfully with GHC 9.8 and all `Vx.*` modules are available

#### Scenario: Executable compiles and links against library
- **WHEN** a developer runs `cabal build exe:vx`
- **THEN** the executable compiles and links against the library component

#### Scenario: Test suite compiles and runs
- **WHEN** a developer runs `cabal test`
- **THEN** the test suite compiles, discovers all `*Spec.hs` files via hspec-discover, and produces a test report

### Requirement: Core module structure
The library SHALL expose four modules: `Vx.Parse` (argument parsing), `Vx.Api` (Nixhub HTTP client), `Vx.Resolve` (version resolution logic), and `Vx.Exec` (nix run execution).

#### Scenario: All modules importable
- **WHEN** test code imports `Vx.Parse`, `Vx.Api`, `Vx.Resolve`, and `Vx.Exec`
- **THEN** all imports resolve and compile successfully

### Requirement: Required dependencies available
The cabal file SHALL declare dependencies on: `optparse-applicative`, `aeson`, `http-client`, `http-client-tls`, `typed-process`, `hspec`, `hspec-discover`, and `QuickCheck`.

#### Scenario: Dependencies resolve
- **WHEN** a developer runs `cabal build` inside `nix develop`
- **THEN** all declared dependencies are available and the build succeeds
