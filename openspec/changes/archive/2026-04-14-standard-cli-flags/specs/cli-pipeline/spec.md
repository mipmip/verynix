## cli-pipeline

### Requirements

1. `vx <pkg>-<version> [args...]` MUST parse the first argument as a package spec and pass remaining arguments through
2. On successful resolution, MUST exec `nix run github:NixOS/nixpkgs/<rev>#<attr_path> -- <args...>`
3. On parse failure, MUST print an error to stderr and exit with code 1
4. On API failure, MUST print the error to stderr and exit with code 1
5. With no arguments, MUST print usage info (via optparse-applicative `--help`) to stderr and exit with code 1
6. Argument parsing MUST use `optparse-applicative` with an Options record containing verbose, no-cache, package spec, and passthrough args

### Test Strategy

- Main.hs is thin wiring — tested via integration (manual: `vx hugo-0.147.9 version`)
- No unit tests for Main.hs
