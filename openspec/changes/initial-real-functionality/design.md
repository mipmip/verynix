## Context

The vx project has a compiled scaffold with stub implementations. All module boundaries and types are defined but nothing works end-to-end. This change makes `vx <pkg>-<version> [args...]` functional by filling in the stubs and wiring the pipeline.

## Goals / Non-Goals

**Goals:**
- `vx hugo-0.147.9 version` resolves via Nixhub API and runs hugo
- Clean process replacement via `execvp` (no child process wrapper)
- Runtime platform detection (no hardcoded system strings)
- Pure JSON parsing layer testable with mocked responses
- Minimal error handling: stderr message + exit 1

**Non-Goals:**
- Subcommands (search, versions, resolve) — future work
- Caching of API responses — future work
- Fuzzy version matching — future work
- Fancy error messages or suggestions — future work
- optparse-applicative CLI framework — keep it simple argv processing

## Decisions

### Two-layer API module
Split `Vx.Api` into a pure parsing function and a thin IO wrapper:
- `parseNixhubResponse :: ByteString -> Either Text NixhubResponse` — pure, testable with canned JSON
- `resolveVersion :: Text -> Text -> IO (Either Text NixhubResponse)` — thin HTTP wrapper

This lets us test JSON parsing without network access and keeps the mock boundary clean.

### executeFile over runProcess_
`executeFile` from `System.Posix.Process` replaces the current process (Unix `execvp`). This is correct for a "run this other program" tool:
- Signals propagate directly (Ctrl+C → nix → hugo)
- Exit code is the child's exit code automatically
- No extra process in the tree

The `unix` package is a GHC boot library, so it adds no fetch overhead. Nix itself is Unix-only, so platform restriction is a non-issue.

### Platform detection from System.Info
`System.Info.arch` and `System.Info.os` map directly to Nix system strings:
```
arch="x86_64", os="linux"  → "x86_64-linux"
arch="aarch64", os="darwin" → "aarch64-darwin"
```
No translation table needed — just `arch <> "-" <> os`.

### Nixhub /v2/resolve endpoint
Use `/v2/resolve?name=<pkg>&version=<ver>` rather than `/v2/pkg?name=<pkg>`. The resolve endpoint returns data for exactly one version, keyed by system. The pkg endpoint returns all versions and would require client-side filtering.

Response structure:
```json
{
  "name": "hugo",
  "version": "0.147.9",
  "systems": {
    "x86_64-linux": {
      "flake_installable": {
        "ref": { "rev": "992f9165..." },
        "attr_path": "hugo"
      }
    }
  }
}
```

We extract `systems.<current-system>.flake_installable.ref.rev` and `systems.<current-system>.flake_installable.attr_path`.

### Coverage threshold lowered to 80%
`Exec.hs` (calls `executeFile`, never returns) and `Main.hs` (thin IO wiring) cannot be meaningfully unit tested. With those excluded from practical testability, 95% is unreachable without contortion. 80% keeps the bar meaningful while accepting the reality of IO-heavy edge modules.

### Minimal argv processing
No `optparse-applicative` for now. Main.hs does:
1. Take first arg, parse as package spec
2. Remaining args become passthrough args
3. Any failure: print to stderr, exit 1

This keeps the tool minimal and fast. Subcommand parsing comes later when we add `search`, `versions`, etc.

## Risks / Trade-offs

- **[Nixhub API availability]** → vx depends entirely on the Nixhub API. If it's down, vx doesn't work. Mitigation: acceptable for v0.1; caching (verynix-9chb) addresses this later.
- **[Platform detection edge cases]** → `System.Info` may report unexpected values on exotic platforms. Mitigation: fail with a clear error showing what was detected vs what's supported.
- **[unix package portability]** → `executeFile` is Unix-only. Mitigation: Nix is Unix-only, so this is a non-issue for the target audience.
