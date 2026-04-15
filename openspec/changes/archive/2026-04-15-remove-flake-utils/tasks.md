## 1. Flake Rewrite

- [x] 1.1 Remove `flake-utils` from `inputs`
- [x] 1.2 Remove `flake-utils` from `outputs` function arguments
- [x] 1.3 Add `systems` list and `forAllSystems` helper
- [x] 1.4 Replace `flake-utils.lib.eachDefaultSystem` with `forAllSystems` for `packages`
- [x] 1.5 Replace `flake-utils.lib.eachDefaultSystem` with `forAllSystems` for `devShells`

## 2. Lock File

- [x] 2.1 Run `nix flake lock` to update `flake.lock` (removes flake-utils entry)

## 3. Verification

- [x] 3.1 Verify `nix develop` provides ghc, cabal, hls, ormolu, hlint
- [x] 3.2 Verify `nix build` produces working `./result/bin/vx`
- [x] 3.3 Verify `nix flake show` lists packages and devShells for all 4 systems
