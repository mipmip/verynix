## Context

The flake currently uses `flake-utils.lib.eachDefaultSystem` to iterate over systems. This is a one-liner convenience that can be replaced with native Nix, eliminating an input dependency.

## Goals / Non-Goals

**Goals:**
- Remove `flake-utils` input entirely
- Produce identical outputs for all default systems
- Keep the flake readable

**Non-Goals:**
- Changing any package definitions or build logic
- Adding or removing supported systems

## Decisions

### genAttrs pattern
Replace `eachDefaultSystem` with:

```nix
let
  systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
in {
  packages = forAllSystems (pkgs: { ... });
  devShells = forAllSystems (pkgs: { ... });
}
```

This is the standard pattern recommended by the Nix community as a flake-utils replacement. `genAttrs` is in `nixpkgs.lib`, so no extra input needed.

### Same systems as flake-utils default
`flake-utils.lib.eachDefaultSystem` uses `[ "aarch64-linux" "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ]`. We use the same list.

## Risks / Trade-offs

- **[Slightly more verbose]** → A `forAllSystems` helper adds 2 lines. Acceptable for removing a dependency.
