# vx: Very niX

Run any version of any Nix package in one command.

```
vx hugo-0.154.3 serve
```

## Why

Nix can run any package from any point in nixpkgs history — but finding the right commit for a specific version is painful. You have to search through nixpkgs history, find the commit hash, and manually construct a `nix run` command.

`vx` does this for you: give it a package name, a version, and your arguments. It resolves the version, finds the right nixpkgs commit, and runs it.

## Status

Pre-development. See [CONTEXT.md](CONTEXT.md) for research and design context.
