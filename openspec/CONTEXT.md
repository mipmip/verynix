# vx: Very niX — Project Context

## Problem Statement

Nix has no built-in way to run a specific version of a package. Users must manually find the nixpkgs commit containing their desired version, then construct a `nix run` command. This is tedious and error-prone.

## Concept

A CLI tool called `vx` (Very niX) that resolves a package version and runs it in one command:

```
vx hugo-0.154.3 serve
```

This translates to:

```
nix run github:NixOS/nixpkgs/<resolved-commit>#hugo -- serve
```

## How Version Resolution Works

The hard part — mapping `package@version` to a nixpkgs commit — is already solved by the **Nixhub API** (operated by Jetify, the makers of Devbox).

### Nixhub API

- **Base URL**: `https://search.devbox.sh/v2`
- **Docs**: https://www.jetify.com/docs/nixhub
- **Web frontend**: https://www.nixhub.io/

#### Key Endpoints

| Endpoint | Purpose |
|---|---|
| `GET /v2/resolve?name=<pkg>&version=<version>` | Resolve a package+version to a nixpkgs commit hash and attr_path |
| `GET /v2/pkg?name=<pkg>` | List all available versions of a package |
| `GET /v2/search?q=<query>` | Search for packages by name |

#### Example: Resolve hugo@0.139.0

```
GET https://search.devbox.sh/v2/resolve?name=hugo&version=0.139.0
```

Returns (among other fields):
- `rev`: `93dc9803a1ee435e590b02cde9589038d5cc3a4e`
- `attr_path`: `hugo`
- Platform-specific data for aarch64-darwin, aarch64-linux, x86_64-darwin, x86_64-linux

#### Resulting Nix Command

```
nix run github:NixOS/nixpkgs/93dc9803a1ee435e590b02cde9589038d5cc3a4e#hugo -- serve
```

## Existing Tools (Prior Art)

| Tool | What it does | Gap |
|---|---|---|
| **nxv** (github.com/jamesbrink/nxv) | Rust CLI, downloads SQLite index of nixpkgs history. `nxv search`, `nxv info`, `nxv history`. | No `run` subcommand — shows commit hash only |
| **nix-versions** (github.com/vic/nix-versions) | Go CLI, queries nixhub/lazamar/search.nixos.org. Generates flakes and devshells. | Focused on devshell/flake generation, no one-shot run |
| **nvs / nix_version_search_cli** (github.com/jeff-hykin/nix_version_search_cli) | Aggregates lazamar, nixhub, history.nix-packages.com. Has `nvs --shell`. | No direct run command, depends on multiple external services |
| **Lazamar's Nix Package Versions** (lazamar.co.uk/nix-versions) | Web UI backed by SQLite (~2M version entries). Open source. | Web only, no public JSON API |
| **Devbox** (jetify.com) | Full dev environment manager using same Nixhub API. `devbox add hugo@0.139.0` | Project-based (devbox.json), not a one-shot runner |

**No existing tool provides the `vx <pkg>-<version> [args...]` → `nix run` pipeline.**

## Core Pipeline

1. **Parse** input: extract package name, version, and passthrough arguments from `vx hugo-0.154.3 serve`
2. **Resolve** version: call Nixhub API `GET /v2/resolve?name=hugo&version=0.154.3`
3. **Extract** `rev` (nixpkgs commit) and `attr_path` from API response
4. **Execute** `nix run github:NixOS/nixpkgs/<rev>#<attr_path> -- <args...>`

## Possible Subcommands

- `vx <pkg>-<version> [args...]` — resolve and run (primary use case)
- `vx search <query>` — search available packages
- `vx versions <pkg>` — list available versions
- `vx resolve <pkg>-<version>` — show the nix run command without executing

## Design Considerations

- The tool should be minimal and fast — it's a thin wrapper around an API call + exec
- Caching resolved versions locally would avoid repeated API calls
- Should handle version matching gracefully (exact match, latest patch, etc.)
- Must pass through all arguments and flags after the package spec to the underlying command
- Should support `--` separator for explicit argument passthrough
- Error messages should be helpful when a version isn't found (suggest available versions)
- Consider Nix flake reference format alternatives (e.g., `nixpkgs/<rev>` vs `github:NixOS/nixpkgs/<rev>`)

## Technology Decision (TBD)

Language choice for implementation is not yet decided. Options:
- **Rust** — fast, single binary, good for CLI tools
- **Go** — fast compilation, single binary
- **Shell script** — minimal, no build step, but limited error handling
- **Nix + shell** — could be packaged as a flake itself
