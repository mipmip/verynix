## cli-flags

### Requirements

1. `vx --help` and `vx -h` MUST print usage information including all available flags and positional arguments
2. `vx --version` and `vx -V` MUST print the version number from the cabal file and exit
3. `vx --verbose` and `vx -v` MUST print resolution details to stderr before executing
4. `vx --no-cache` MUST bypass the local cache (existing behavior, migrated to optparse)
5. Flags MUST be parseable before the package spec: `vx --verbose --no-cache hugo-0.147.9 serve`
6. All arguments after the package spec MUST be passed through to the executed command
7. Verbose output MUST show: resolving message, API URL or cache hit, resolved flake ref, exec command
8. Verbose output MUST go to stderr (not stdout)
9. `--help` output MUST include a brief program description

### Test Strategy

- Flag parsing is handled by optparse-applicative (well-tested library)
- Verbose output format verified via integration test
- Version output verified via integration test
