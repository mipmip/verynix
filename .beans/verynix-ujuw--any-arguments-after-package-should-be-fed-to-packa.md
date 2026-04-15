---
# verynix-ujuw
title: any arguments after package should be fed to package
status: completed
type: task
priority: normal
openspec-link: openspec/changes/archive/2026-04-15-strict-arg-ordering
created_at: 2026-04-14T21:33:40Z
updated_at: 2026-04-15T10:00:00Z
---

I don't know if the option parser allows this strict ordering rules but ordering is very important. after [package-<version>] all extra strings are owner by the package and not the vx application. The vx application should always opass these through the package binary.

vx [vx flags/options] [package-<version>] [package commands/flags/options]

