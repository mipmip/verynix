## Context

`optparse-applicative` by default treats `--help`, `--version`, and other `--` flags as its own options regardless of position. This conflicts with the strict ordering requirement: `vx [vx-flags] <package> [package-args]`.

## Goals / Non-Goals

**Goals:**
- Strict ordering: `vx [vx flags] <package>[-<version>] [package commands/flags/options]`
- Everything after the package spec is passed through verbatim
- `vx hugo --help` runs hugo's help
- `vx --help` shows vx help

**Non-Goals:**
- Mixed flag ordering (vx flags interspersed with package args)

## Decisions

### Two-phase argument parsing
Instead of letting optparse-applicative parse all arguments, split argv manually:

1. Find the first argument that looks like a package spec (doesn't start with `-`)
2. Everything before it is vx flags → feed to optparse-applicative
3. The package spec and everything after → handle manually

This gives complete control over the boundary. optparse-applicative handles vx's own flags cleanly, and nothing after the package spec is ever touched by the parser.

### Implementation approach
Use `System.Environment.getArgs` to get raw argv, then split:

```
argv: ["--verbose", "--no-cache", "hugo-0.147.9", "--help", "serve"]
       ├── vx flags ──────────────┤├── package ──┤├── passthrough ────────┤
```

Parse vx flags with optparse using `handleParseResult . execParserPure defaultPrefs`. Parse the package spec with existing `parsePackageSpec`. Pass the rest through verbatim.

### Retain optparse for vx flags
optparse-applicative still handles `--help`, `--version`, `--verbose`, `--no-cache` — but only for the vx-flags portion. When there's no package spec (just `vx --help`), all args go to optparse and it shows help naturally.

## Risks / Trade-offs

- **[Manual argv splitting]** → Slightly more code than pure optparse, but gives exact control over the boundary.
- **[--help before package spec]** → `vx --help hugo` would show vx help because `--help` is before the package. This matches the strict ordering rule and is correct behavior.
