## ADDED Requirements

### Requirement: README has installation instructions
The README SHALL include instructions for installing/running vx via Nix flakes.

#### Scenario: User finds install instructions
- **WHEN** a user reads the README
- **THEN** they find a `nix run` or `nix build` command to install vx

### Requirement: README explains how it works
The README SHALL include a section explaining the resolve pipeline: parse input, call Nixhub API, build nix run command, execute.

#### Scenario: User understands the pipeline
- **WHEN** a user reads the "How it works" section
- **THEN** they understand the four steps: parse, resolve, build command, execute

### Requirement: README shows planned usage
The README SHALL list all planned subcommands with their intended syntax and a clear indication of implementation status.

#### Scenario: User sees planned commands
- **WHEN** a user reads the usage section
- **THEN** they see the planned commands and can distinguish implemented from unimplemented ones

### Requirement: README has current status
The README SHALL accurately reflect the current project status (not "pre-development").

#### Scenario: Status is accurate
- **WHEN** a user reads the status section
- **THEN** it reflects that the project scaffold is built but core functionality is not yet implemented
