# test-framework Specification

## Purpose
TBD - created by archiving change haskell-project-setup. Update Purpose after archive.
## Requirements
### Requirement: Hspec with auto-discovery
The test suite SHALL use hspec as the test framework with `hspec-discover` for automatic test file discovery. A `test/Spec.hs` file SHALL serve as the discovery entry point.

#### Scenario: Auto-discovery finds test modules
- **WHEN** a new `test/Vx/FooSpec.hs` file is added following hspec conventions
- **THEN** `cabal test` automatically discovers and runs tests from that file without manual registration

### Requirement: Test modules for each source module
Each `Vx.*` source module SHALL have a corresponding `Vx.*Spec` test module with at least one test (pending tests are acceptable for the initial scaffold).

#### Scenario: All spec files present
- **WHEN** the test suite runs
- **THEN** test output shows entries for `Vx.Parse`, `Vx.Api`, `Vx.Resolve`, and `Vx.Exec`

### Requirement: QuickCheck available for property tests
QuickCheck SHALL be available as a test dependency so property-based tests can be written alongside hspec examples.

#### Scenario: Property test compiles
- **WHEN** a test file uses `Test.Hspec.QuickCheck` (e.g., `prop`)
- **THEN** the property test compiles and runs within the hspec suite

### Requirement: Coverage target of 95%
The project SHALL enforce a minimum code coverage target of 95% as measured by GHC's HPC. Coverage below this threshold SHALL cause the coverage check to fail.

#### Scenario: Coverage meets threshold
- **WHEN** coverage is at or above 95%
- **THEN** the coverage check passes

#### Scenario: Coverage below threshold
- **WHEN** coverage drops below 95%
- **THEN** the coverage check fails with a message indicating current coverage and the 95% target

