## cli-flags

### Requirements

1. `vx --help` and `vx -h` MUST print usage information including all available flags and positional arguments
2. `vx --version` and `vx -V` MUST print the version number from the cabal file and exit
3. `vx --verbose` and `vx -v` MUST print resolution details to stderr before executing
4. `vx --no-cache` MUST bypass the local cache
5. vx flags MUST appear before the package spec
6. All arguments after the package spec MUST be passed through to the executed command verbatim, including flags like `--help` and `--version`
7. `vx hugo --help` MUST pass `--help` to hugo, not show vx help
8. `vx hugo --version` MUST pass `--version` to hugo, not show vx version
9. Verbose output MUST show: resolving message, API URL or cache hit, resolved flake ref, exec command
10. Verbose output MUST go to stderr
11. `--help` output MUST show the package spec metavar as `<package>[-<version>]` indicating version is optional

### Test Strategy

- Flag parsing verified via integration tests
- Test `vx hugo --help` passes through correctly
- Test `vx --help` shows vx help
