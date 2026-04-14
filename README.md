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
nix run github:mipmip/verynix
```

Or build locally:

```bash
git clone https://github.com/mipmip/verynix.git
cd verynix
nix build
./result/bin/vx
```

## Usage

```
vx [-v|--verbose] [--no-cache] <package>[-<version>] [ARGS...]
```

### Run a specific version

```bash
vx hugo-0.147.9 serve
vx nodejs-20.11.0 --version
vx python3-3.12.0 -c "print('hello')"
```

### Run the latest version

```bash
vx hugo serve           # omit version for latest
vx hugo-latest serve    # or use "latest" explicitly
```

### Flags

| Flag | Short | Description |
|---|---|---|
| `--verbose` | `-v` | Show resolution details (API URL, resolved commit, exec command) |
| `--no-cache` | | Bypass the local cache |
| `--version` | `-V` | Show vx version |
| `--help` | `-h` | Show usage info |

### Examples

```bash
# Run hugo 0.147.9 and start the dev server
vx hugo-0.147.9 serve

# See what's happening under the hood
vx --verbose hugo-0.147.9 version

# Run latest hugo without caching
vx --no-cache hugo serve
```

When a requested version doesn't exist, vx shows the nearest available versions:

```
$ vx hugo-0.149.1 version
version 0.149.1 of hugo not found

nearest available versions:
  < 0.148.2
  > 0.150.0
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute and [DEVELOPMENT.md](DEVELOPMENT.md) for development setup.

## Using AI

This project is without any hesitation made together with AI Coding agents
using OpenSpec methodology.


