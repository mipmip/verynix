## 1. Dependencies

- [x] 1.1 Add `optparse-applicative` to executable build-depends in `vx.cabal`
- [x] 1.2 Add `Paths_vx` to `other-modules` in the executable section of `vx.cabal`

## 2. Options Parser

- [x] 2.1 Define `Options` record in `app/Main.hs` with `optVerbose :: Bool`, `optNoCache :: Bool`, `optSpec :: String`, `optArgs :: [String]`
- [x] 2.2 Build optparse-applicative parser for the Options record
- [x] 2.3 Add `--verbose` / `-v` switch
- [x] 2.4 Add `--no-cache` switch
- [x] 2.5 Add `--version` / `-V` via `infoOption` using `Paths_vx.version`
- [x] 2.6 Add program description for `--help` output

## 3. Verbose Logging

- [x] 3.1 Add verbose logging: "resolving <pkg> <ver> for <system>..."
- [x] 3.2 Add verbose logging: "GET <url>" or "cache hit: <flakeref>"
- [x] 3.3 Add verbose logging: "resolved: <flakeref>"
- [x] 3.4 Add verbose logging: "exec: nix run <flakeref> -- <args>"
- [x] 3.5 All verbose output MUST go to stderr

## 4. Main.hs Rewrite

- [x] 4.1 Replace hand-rolled arg parsing with optparse-applicative `execParser`
- [x] 4.2 Wire Options record through the existing pipeline (resolve, cache, exec)
- [x] 4.3 Preserve all existing behavior (--no-cache, version suggestions, cache flow)

## 5. Verification

- [x] 5.1 Verify `cabal build` compiles
- [x] 5.2 Verify `cabal test` passes
- [x] 5.3 Verify `nix build` produces working binary
- [x] 5.4 Verify `vx --help` shows usage info
- [x] 5.5 Verify `vx --version` shows version
- [x] 5.6 Verify `vx --verbose hugo-0.147.9 version` shows resolution details then runs
- [x] 5.7 Verify `vx hugo-0.147.9 version` still works (no verbose output)
