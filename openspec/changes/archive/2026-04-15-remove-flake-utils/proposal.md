## Why

The `flake-utils` input is an unnecessary dependency. Its `eachDefaultSystem` helper can be replaced with a few lines of native Nix using `nixpkgs.lib.genAttrs`. Fewer inputs means simpler `flake.lock`, faster evaluations, and one less thing to update.

**Task**: [verynix-bga2 — replace flake-utils with native nix](.beans/verynix-bga2--replace-flake-utils-with-native-nix.md)

## What Changes

- Remove `flake-utils` from `inputs`
- Replace `flake-utils.lib.eachDefaultSystem` with `nixpkgs.lib.genAttrs` over a systems list
- Remove `flake-utils` from `flake.lock`

## Capabilities

### New Capabilities
_None._

### Modified Capabilities
- `nix-integration`: Flake restructured to use native Nix instead of flake-utils

## Impact

- Modified files: `flake.nix`, `flake.lock`
- Removed dependency: `flake-utils`
- No changes to Haskell source code
- All outputs (packages, devShells) remain identical
