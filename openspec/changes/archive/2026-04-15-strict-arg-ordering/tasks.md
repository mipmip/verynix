## 1. Two-Phase Argument Parsing

- [x] 1.1 Split argv into vx-flags (before first non-flag arg) and package+passthrough (the rest)
- [x] 1.2 Define `VxFlags` record with `flagVerbose :: Bool`, `flagNoCache :: Bool` (no package spec or passthrough)
- [x] 1.3 Build optparse-applicative parser for VxFlags only (with --help, --version)
- [x] 1.4 Parse vx-flags portion with `execParserPure` + `handleParseResult`
- [x] 1.5 Extract package spec as first element of remainder, rest as passthrough args
- [x] 1.6 Remove old `Options` record and `optionsParser`

## 2. Wire Pipeline

- [x] 2.1 Wire new two-phase parsing into `main` function
- [x] 2.2 Preserve all existing behavior (verbose, no-cache, latest, cache, version suggestions)

## 3. Verification

- [x] 3.1 Verify `cabal build` compiles
- [x] 3.2 Verify `cabal test` passes
- [x] 3.3 Verify `nix build` produces working binary
- [x] 3.4 Verify `vx --help` shows vx help
- [x] 3.5 Verify `vx --version` shows vx version
- [x] 3.6 Verify `vx hugo --help` passes --help to hugo (not vx)
- [x] 3.7 Verify `vx --verbose hugo version` shows verbose output
- [x] 3.8 Verify `vx hugo-0.147.9 version` still works
