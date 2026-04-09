## Context

The project has a working Haskell scaffold with flake, cabal, hspec tests, and coverage. The README still says "pre-development" and there's no developer guide. This is a solo learning project — docs are for future-me.

## Goals / Non-Goals

**Goals:**
- README that sells the project and shows how to use it
- Developer guide that gets future-me productive in 5 minutes
- Document planned features clearly as "not yet implemented"

**Non-Goals:**
- API documentation (no public API yet)
- User manual (tool doesn't work yet)
- Contribution process / PR templates (solo project)

## Decisions

### README structure
Keep it focused and scannable. Lead with the hook, explain the pipeline, show installation and planned usage. The CONTEXT.md stays as the deep research document — README links to it but doesn't duplicate it.

### CONTRIBUTING.md as developer guide
Using CONTRIBUTING.md as the filename is conventional even for solo projects — GitHub/forges surface it automatically. Content is practical: every command you need, the project layout, and the recipe for adding a new module.

### Show planned commands in README
Mark unimplemented commands clearly rather than hiding them. This communicates the vision and scope. Use a "Status" column in a table or clear markers.

## Risks / Trade-offs

- **[Docs go stale]** → Keep docs minimal and tied to concrete commands. Less prose = less to maintain.
- **[Planned features mislead]** → Use clear "not yet implemented" markers so nobody thinks these work.
