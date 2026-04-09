# vx: Very niX

Run any version of any Nix package in one command.

```
vx hugo-0.154.3 serve
```

## Why

Nix can run any package from any point in nixpkgs history — but finding the right commit for a specific version is painful. You have to search through nixpkgs history, find the commit hash, and manually construct a `nix run` command.

`vx` does this for you: give it a package name, a version, and your arguments. It resolves the version, finds the right nixpkgs commit, and runs it.

## How it works

```
vx hugo-0.154.3 serve
 │
 ├─ 1. Parse: extract package="hugo", version="0.154.3", args=["serve"]
 │
 ├─ 2. Resolve: call Nixhub API
 │     GET https://search.devbox.sh/v2/resolve?name=hugo&version=0.154.3
 │     → rev="93dc980...", attr_path="hugo"
 │
 ├─ 3. Build command:
 │     nix run github:NixOS/nixpkgs/93dc980...#hugo -- serve
 │
 └─ 4. Execute: run the command
```

The version resolution uses the [Nixhub API](https://www.nixhub.io/) (by Jetify), which maps package names and versions to nixpkgs commits.

## Installation

```bash
nix run github:pim-hoeven/verynix
```

Or build locally:

```bash
git clone https://github.com/pim-hoeven/verynix.git
cd verynix
nix build
./result/bin/vx
```

## Usage

| Command | Description | Status |
|---|---|---|
| `vx <pkg>-<version> [args...]` | Resolve and run a package | Not yet implemented |
| `vx search <query>` | Search available packages | Not yet implemented |
| `vx versions <pkg>` | List available versions | Not yet implemented |
| `vx resolve <pkg>-<version>` | Show the nix run command without executing | Not yet implemented |

## Status

Scaffold built — the Haskell project compiles, tests run, and coverage reports. Core functionality (version resolution, execution) is not yet implemented.

See [CONTEXT.md](CONTEXT.md) for research and design context. See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup.
