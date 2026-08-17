---
description: Check the vendored skills against their upstream repos, and pull in what changed.
---

Run `sh scripts/sync-vendored.sh` from the repo root to see whether any skill
vendored in `vendor/UPSTREAM.json` has moved upstream. Pass `$ARGUMENTS` through
to the script.

If it reports drift:

1. Show me the diff it printed, grouped by skill, and say what each change
   actually does — not just that lines moved.
2. Ask whether I want it. Some upstream changes are not worth taking.
3. On a yes, run `sh scripts/sync-vendored.sh --apply`. That copies the new
   files and records the new SHA, but deliberately **skips** every file listed
   under `deltas` in the manifest.
4. For each skipped delta file, port the upstream change by hand, keeping the
   local change intact. Then set that delta's own `synced` in the manifest to
   the source's `synced` — until you do, the script keeps reporting the change
   on every run. Tell me what you kept and why.
5. Bump the shared version in every `plugins/*/.claude-plugin/plugin.json` and
   every `marketplace.json` plugin entry, and update the skill's row in
   `README.md` if what it does changed.

Do not commit. Leave the working tree for me to review.
