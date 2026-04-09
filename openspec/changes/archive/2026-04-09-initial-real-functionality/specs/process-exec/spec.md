## process-exec

### Requirements

1. `execNixRun` MUST call `executeFile` from `System.Posix.Process` (Unix `execvp` semantics)
2. `execNixRun` MUST replace the current process — it does not return on success
3. The executed command MUST be `nix` with args `["run", "<flake-ref>", "--"] ++ <passthrough-args>`
4. `execNixRun` MUST search PATH for the `nix` binary (use `True` for `usePATH` in `executeFile`)

### Test Strategy

- Not unit-testable (`executeFile` never returns)
- Tested via integration (manual: `vx hugo-0.147.9 version`)
