---
description: Create or audit a repo's README.md, CLAUDE.md, and REVIEW.md docs.
argument-hint: "[--readme] [--claude] [--review]"
---

Invoke the **sync-core-repo-docs** skill to create or audit this repo's core docs.

Pass the arguments below straight through to the skill as its target flags —
`--readme`, `--claude`, `--review`. They combine, and **no flags means process
all three** in the canonical README → CLAUDE → REVIEW order. The skill owns the
runbook (create-vs-audit paths, the confirmation checkpoint, the ordering); this
command only routes the invocation and its flags.

Arguments: $ARGUMENTS
