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
  array of paths to skill directories. `name` and `version` must match the
  corresponding marketplace entry.
- `skills/<skill-name>/SKILL.md` — the skill. One per directory. The directory
  name is the skill name.

When adding or removing a skill, update both `plugin.json` (add to `skills`
array) and — if the plugin's surface area changed meaningfully — bump `version`
in both `plugin.json` and the matching `marketplace.json` plugin entry together.
Also update the "Skills included" table in `README.md`: add the new skill in
alphabetical order with a one-line summary of what it does, or remove the row
on deletion.

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
it as..."). A vague description means the skill never fires.

The body of `SKILL.md` is the runbook Claude follows once invoked. Conventions
used throughout this repo:

- **Numbered `## Step N` sections** for linear workflows. Each step has a single
  clear action.
- **Explicit stop-and-ask checkpoints** for destructive or ambiguous operations
  — never push past a checkpoint without user confirmation.
- **Inline shell commands** written for bash (this repo targets a Windows
  machine running bash via Git for Windows; use Unix shell syntax, forward
  slashes, `/dev/null`).
- **"Things not to do" / "What this doesn't touch"** sections near the end to
  prevent scope creep when Claude executes the skill.

## Testing a change

No automated validation exists. To verify a change:

1. Reload the plugin in Claude Code (via the marketplace).
2. Trigger the skill with a phrase from its `description` and confirm it runs.

If the skill doesn't fire, the `description` is usually the problem — not the
body.

## Conventions worth preserving

- Skill descriptions are verbose and enumerate trigger phrases. Resist the urge
  to tighten them — terse descriptions miss matches.
- Skills that rewrite history, push, or otherwise take destructive actions must
  require explicit user confirmation at the relevant step. The existing skills
  model this carefully; match that style when adding new ones.
- Commit signing is mandatory on this repo. If a commit fails with a
  1Password-related signing error, retry with `-c commit.gpgsign=false`
  (standing authorization from global CLAUDE.md).
