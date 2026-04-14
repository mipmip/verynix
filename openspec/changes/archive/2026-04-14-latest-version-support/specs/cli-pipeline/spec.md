## cli-pipeline

### Requirements

1. `vx <pkg>-<version> [args...]` MUST parse the first argument as a package spec and pass remaining arguments through
2. `vx <pkg> [args...]` (no version) MUST resolve and run the latest version
3. `vx <pkg>-latest [args...]` MUST resolve and run the latest version
4. On successful resolution, MUST exec `nix run github:NixOS/nixpkgs/<rev>#<attr_path> -- <args...>`
5. On parse failure, MUST print an error to stderr and exit with code 1
6. On API failure, MUST print the error to stderr and exit with code 1
7. With no arguments, MUST print usage info to stderr and exit with code 1
8. Argument parsing MUST use `optparse-applicative` with an Options record
9. When version is omitted or "latest", cache MUST be skipped (no read, no write)
10. Verbose mode MUST show "(latest)" when resolving without a pinned version

### Test Strategy

- Main.hs is thin wiring — tested via integration
- No unit tests for Main.hs
