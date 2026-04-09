---
# verynix-bu4v
title: show near versions when not existing
status: completed
type: task
priority: normal
created_at: 2026-04-09T14:27:32Z
openspec-link: openspec/changes/archive/2026-04-09-show-near-versions
updated_at: 2026-04-09T15:30:00Z
---

when i run `cabal run vx hugo-0.149.1 version'
i get this error:

`resolve failed: API returned status 404`

This is caused because 0.149.1 does not exist. Show a more descriptive message and show the most near versions lower and greater then. If they are available.
