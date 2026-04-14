## 1. Parse Changes

- [x] 1.1 Change `packageVersion` in `PackageSpec` from `Text` to `Maybe Text`
- [x] 1.2 Update `parsePackageSpec` to return `Nothing` version when input has no hyphen-digit (e.g., `"hugo"`)
- [x] 1.3 Update `parsePackageSpec` to normalize `"latest"` to `Nothing` (e.g., `"hugo-latest"` → `PackageSpec "hugo" Nothing`)
- [x] 1.4 Update existing parse tests for new `Maybe Text` type
- [x] 1.5 Add parse tests for `"hugo"` → `PackageSpec "hugo" Nothing`
- [x] 1.6 Add parse tests for `"hugo-latest"` → `PackageSpec "hugo" Nothing`

## 2. Pipeline Changes

- [x] 2.1 Update `app/Main.hs` to pass `"latest"` to `resolveVersion` when `packageVersion` is `Nothing`
- [x] 2.2 Skip cache read/write when version is `Nothing` (latest)
- [x] 2.3 Update verbose logging to show `(latest)` when version is `Nothing`

## 3. Help Text

- [x] 3.1 Update optparse metavar from `<package>-<version>` to `<package>[-<version>]`

## 4. Verification

- [x] 4.1 Verify `cabal build` compiles
- [x] 4.2 Verify `cabal test` passes
- [x] 4.3 Verify `nix build` produces working binary
- [x] 4.4 Verify `vx hugo version` runs latest hugo
- [x] 4.5 Verify `vx hugo-latest version` runs latest hugo
- [x] 4.6 Verify `vx hugo-0.147.9 version` still works (pinned)
- [x] 4.7 Verify `vx --verbose hugo version` shows "(latest)" in output
- [x] 4.8 Verify `vx --help` shows updated metavar
