## Why

Currently `optparse-applicative` intercepts flags like `--help` and `--version` even when they appear after the package spec. This means `vx hugo --help` shows vx's help instead of passing `--help` to hugo. Everything after the package spec should belong to the package, not to vx.

**Task**: [verynix-ujuw — any arguments after package should be fed to package](.beans/verynix-ujuw--any-arguments-after-package-should-be-fed-to-packa.md)

## What Changes

- All arguments after `<package>[-<version>]` are passed through to the package unchanged
- vx flags (`--verbose`, `--no-cache`) must appear before the package spec
- `vx hugo --help` passes `--help` to hugo (not vx)
- `vx hugo --version` passes `--version` to hugo (not vx)
- `vx --help` still shows vx help (no package spec before it)

## Capabilities

### New Capabilities
_None._

### Modified Capabilities
- `cli-flags`: Enforce strict ordering — vx flags before package spec, everything after is passthrough

## Impact

- Modified files: `app/Main.hs`
- No new dependencies
- No library changes
