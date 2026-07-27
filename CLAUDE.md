# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## What this repo is

A Claude Code **plugin marketplace** (`claude-skills`) that publishes a single
plugin (`esond`) containing Eric's personal skills. There is no build, no tests,
no runtime — Claude Code consumes the repo directly by reading the manifest JSON
and skill markdown files.

## Manifest layout

Three files drive discovery; changing one without the others will break loading:

- `.claude-plugin/marketplace.json` — declares the marketplace and lists its
  plugins. Each plugin entry has `name`, `source` (relative path to plugin
  root), `description`, `version`.
- `.claude-plugin/plugin.json` — declares the plugin itself. `skills` is an
  array of paths to skill directories; `agents` (optional) is an array of paths
  to bundled subagent definition files. `name` and `version` must match the
  corresponding marketplace entry.
- `skills/<skill-name>/SKILL.md` — the skill. One per directory. The directory
  name is the skill name.
- `agents/<name>.md` — a subagent bundled for a skill to spawn.
  Frontmatter sets its
  `name`, `description`, `tools`, and a pinned `model`; the file body is the
  agent's prompt. Listed in `plugin.json` under `agents`, and invoked by a skill
  via `subagent_type` rather than by the user.
- `hooks/hooks.json` — event handlers, auto-discovered at the plugin root, so
  `plugin.json` does not list them. Scripts live beside it in `hooks/` and are
  invoked via `${CLAUDE_PLUGIN_ROOT}`. A hook fires for every session, so it
  must exit 0 on all failure paths rather than block startup. Write them in
  POSIX `sh` (Git Bash runs them on Windows); `.gitattributes` pins `*.sh` to
  LF, since CRLF survives Git Bash but breaks dash.

When adding or removing a skill, update both `plugin.json` (add to `skills`
array) and — if the plugin's surface area changed meaningfully — bump `version`
in both `plugin.json` and the matching `marketplace.json` plugin entry together.
Also update the "Skills included" table in `README.md`: add the new skill in
alphabetical order with a one-line summary of what it does, or remove the row
on deletion.

When a skill bundles a subagent, add its file under `agents/`, list it in
`plugin.json`'s `agents` array, and add a row to the "Agents included" table in
`README.md`.

When a skill bundles a hook, add the script under `hooks/`, register it in
`hooks/hooks.json`, and add a row to the "Hooks included" table in `README.md`.
A hook that changes Claude's behavior should be opt-in and reversible from the
skill that owns it, so the hook stays inert until the user turns it on.

## Authoring skills

Every skill is a single `SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name # must match the directory name
description: | # THIS is how Claude decides to invoke the skill
  ...
---
```

The `description` field is the discovery mechanism — Claude reads it to decide
whether a user's request matches this skill. Write descriptions that enumerate
triggering phrases and scenarios explicitly (see existing skills for the
pattern: "Use this skill whenever the user says X, Y, or Z — even if they phrase
it as..."). A vague description means the skill never fires. Keep the
description under ~1024 characters, though — marketplace upload validation
rejects longer ones, so enumerate triggers but trim to fit.

The body of `SKILL.md` is the runbook Claude follows once invoked. Conventions
used throughout this repo:

- **Numbered `## Step N` sections** for linear workflows. Each step has a single
  clear action.
- **Explicit stop-and-ask checkpoints** for destructive or ambiguous operations
  — never push past a checkpoint without user confirmation.
- **"Things not to do" / "What this doesn't touch"** sections near the end to
  prevent scope creep when Claude executes the skill.

## Testing a change

CI runs the `validate` job in `.github/workflows/release.yml` on every pull
request and every push to `main`. It checks that both manifests parse, that
their versions match, that every path in `plugin.json`'s `skills` array has a
`SKILL.md`, and that each skill's frontmatter carries `name` and `description`
with `name` matching its directory. Run the same structural checks locally with
`claude plugin validate .claude-plugin/plugin.json`, which also covers
`hooks/hooks.json` syntax.

Nothing automated executes a skill, so behavior is still verified by hand:

1. Reload the plugin in Claude Code (via the marketplace).
2. Trigger the skill with a phrase from its `description` and confirm it runs.

Edits to a `SKILL.md` body apply immediately. Changes under `hooks/` do not —
run `/reload-plugins` or restart.

If the skill doesn't fire, the `description` is usually the problem — not the
body.

## Conventions worth preserving

- Skill descriptions are verbose and enumerate trigger phrases. Resist the urge
  to tighten them — terse descriptions miss matches.
- Skills that rewrite history, push, or otherwise take destructive actions must
  require explicit user confirmation at the relevant step. The existing skills
  model this carefully; match that style when adding new ones.
