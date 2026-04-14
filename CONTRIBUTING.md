# Contributing to vx

Thanks for your interest in contributing to vx!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Set up the development environment — see [DEVELOPMENT.md](DEVELOPMENT.md)

## Submitting Changes

1. Create a branch for your change
2. Make your changes, keeping commits focused and well-described
3. Make sure tests pass: `cabal test`
4. Format your code: `ormolu --mode inplace src/**/*.hs app/**/*.hs test/**/*.hs`
5. Open a pull request against `main`

## Pull Request Guidelines

- Keep PRs focused on a single change
- Add tests for new functionality
- Update the `## [Unreleased]` section in [CHANGELOG.md](CHANGELOG.md) with a summary of your change
- Make sure the build passes: `nix build`

## Reporting Issues

- Use [GitHub Issues](https://github.com/mipmip/verynix/issues) to report bugs or request features
- Include the output of `vx --version` and `vx --verbose` when reporting bugs

## Development Setup

See [DEVELOPMENT.md](DEVELOPMENT.md) for build instructions, testing, code style, and project structure.
