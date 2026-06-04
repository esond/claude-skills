# Review guidance

Reviewer-facing notes for `/code-review`, `/security-review`, and `/review`.
This repo has no build or tests — review focuses on manifest integrity and the
safety of what each skill instructs Claude to do, not runtime bugs.

## Review priorities

1. **Manifest integrity.** Any change touching a skill must keep three things in
   agreement (CLAUDE.md gives the authoring rule — verify it actually held):
   `plugin.json` lists the skill dir; `plugin.json` and `marketplace.json`
   versions are identical; the README "Skills included" table has a matching
   alphabetical row.
2. **Description length.** Each SKILL.md `description` must stay under the
   ~1024-char upload-validation ceiling (see CLAUDE.md "Authoring skills").
   Over-length descriptions fail marketplace upload — check any added/edited one.
3. **Trigger quality.** A new/changed `description` should enumerate concrete
   trigger phrases; a terse one silently fails to fire.

## Security-sensitive surfaces

- **Destructive skills.** Skills that rewrite git history, push, delete files, or
  edit tracked source must gate those actions behind an explicit stop-and-ask
  checkpoint. Scrutinize any new skill that takes such an action without one.
- **Shell commands in skills.** Review inline/bundled commands for unsafe patterns
  (unscoped `rm -rf`, `git checkout --` that discards work, force-push) and confirm
  they match the user's stated intent.

## Known false positives — do not flag

- Absence of build/test/CI — there is no runtime; by design.
- Forward slashes, `/dev/null`, Unix shell syntax in skill bodies — CLAUDE.md
  mandates bash for skill commands; intentional, not a Windows bug.
- Verbose, repetitive skill `description` fields — verbosity is a deliberate
  triggering strategy.
