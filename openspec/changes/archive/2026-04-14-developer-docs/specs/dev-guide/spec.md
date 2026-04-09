## ADDED Requirements

### Requirement: Developer guide covers prerequisites
The CONTRIBUTING.md SHALL list prerequisites (Nix with flakes enabled).

#### Scenario: Developer checks prerequisites
- **WHEN** a developer reads the prerequisites section
- **THEN** they know they need Nix with flakes enabled

### Requirement: Developer guide covers setup and build
The CONTRIBUTING.md SHALL document how to enter the dev shell, build, run, and test the project.

#### Scenario: Developer builds the project
- **WHEN** a developer follows the setup instructions
- **THEN** they can run `nix develop`, `cabal build`, `cabal test`, and `cabal run vx`

### Requirement: Developer guide covers coverage
The CONTRIBUTING.md SHALL document how to run coverage and what the target is.

#### Scenario: Developer runs coverage
- **WHEN** a developer follows the coverage instructions
- **THEN** they can run `nix build .#coverage` and understand the 95% target

### Requirement: Developer guide covers code style
The CONTRIBUTING.md SHALL document the formatting (ormolu) and linting (hlint) tools and how to run them.

#### Scenario: Developer formats code
- **WHEN** a developer reads the code style section
- **THEN** they know to run `ormolu` for formatting and `hlint` for linting

### Requirement: Developer guide shows project structure
The CONTRIBUTING.md SHALL include a module map showing the source and test layout.

#### Scenario: Developer finds module map
- **WHEN** a developer reads the project structure section
- **THEN** they see which files exist and what each module is responsible for

### Requirement: Developer guide explains adding a new module
The CONTRIBUTING.md SHALL document the full steps to add a new Haskell module: create the `.hs` file, update `.cabal`, create the test spec.

#### Scenario: Developer adds a module
- **WHEN** a developer follows the "adding a module" instructions
- **THEN** they know to create the source file, add it to `exposed-modules` in `vx.cabal`, and create a corresponding `*Spec.hs` test file
