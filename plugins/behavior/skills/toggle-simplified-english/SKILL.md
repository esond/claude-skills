---
name: toggle-simplified-english
description: |
  Enable, disable, or toggle the Simplified Technical English (STE) output
  style by editing the Claude Code settings file — no manual JSON editing.
  Use this skill whenever the user asks to turn on/off, enable/disable,
  activate/deactivate, or toggle "simplified english", "simplified technical
  english", "STE", "the STE style", or "the simplified english output style" —
  even phrased as "switch to simplified english", "go back to the default
  output style", "stop talking in STE", "put me in STE mode", or "is
  simplified english on?" (report state without changing it). Handles user
  scope (~/.claude/settings.json, the default) or project scope
  (.claude/settings.local.json) when the user says "just for this
  project"/"here only".
---

# toggle-simplified-english

Flips the `outputStyle` setting between `behavior:Simplified Technical
English` and the default, editing the settings JSON so the user doesn't have
to. The style itself ships in this same plugin, so if this skill fired, the
style is installed.

## Step 1 — work out the intent and scope

- **Enable**, **disable**, or **toggle** from the user's phrasing. A bare
  "toggle" means flip whatever Step 2 finds. A pure status question ("is STE
  on?") means report and stop — change nothing.
- Scope defaults to **user**: `~/.claude/settings.json`. Only use project
  scope — `.claude/settings.local.json` in the current repo — when the user
  says something like "just for this project" or "only here".

## Step 2 — read the current state

Read the scoped settings file and note the current `outputStyle` value (the
key may be absent, which means the default style — possibly overridden at
another scope; mention that only if relevant).

- File missing and **disabling**: nothing to do. Report that STE isn't set at
  this scope and stop.
- `outputStyle` is some other non-default style and **enabling**: only one
  output style can be active. Tell the user what it would replace and get a
  yes before proceeding.
- Already in the requested state: say so and stop. Don't rewrite the file.

## Step 3 — make the edit

Preserve every other key and the file's existing formatting; touch only
`outputStyle`.

- **Enable**: set `"outputStyle": "behavior:Simplified Technical English"`.
  If the file doesn't exist, create it containing just that key.
- **Disable**: remove the `outputStyle` key entirely, which falls back to the
  default style (or whatever a lower-precedence scope sets).

## Step 4 — report

State what changed (old value → new value, and in which file) and remind the
user it takes effect on the next `/clear` or new session — the current
session keeps its already-built system prompt.

## Things not to do

- Don't touch any settings key other than `outputStyle`.
- Don't edit enterprise/managed policy files or `.claude/settings.json`
  (shared project settings) — project scope means `settings.local.json`.
- Don't run `/clear` or restart anything on the user's behalf.
- Don't reformat, reorder, or "clean up" the rest of the settings file.
