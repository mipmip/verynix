## platform-detection

### Requirements

1. `currentSystem` MUST return a Nix system string in the format `<arch>-<os>` (e.g., `x86_64-linux`)
2. `currentSystem` MUST derive arch from `System.Info.arch` and os from `System.Info.os`
3. `nixSystem` MUST be a pure function `String -> String -> Text` for testability
4. Known valid outputs: `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`

### Test Strategy

- Unit test `nixSystem` with known arch/os string combinations
- Test edge cases: unexpected arch or os values still produce `<arch>-<os>` format
