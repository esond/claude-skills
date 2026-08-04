---
name: toggle-simplified-english
description: >-
  Enable, disable, or toggle the Simplified Technical English (STE) output
  style by editing the `outputStyle` key in Claude Code settings — no manual
  JSON editing. Explicit-only: invoked by name, never auto-triggered, because
  it writes to a settings file.
disable-model-invocation: true
---

# toggle-simplified-english

Flips the `outputStyle` setting between `behavior:Simplified Technical
English` and the default, editing the settings JSON so the user doesn't have
to. The style itself ships in this same plugin, so if this skill ran, the
style is installed.

## Step 1 — work out the intent, then confirm the scope

- **Enable**, **disable**, or **toggle** from the user's phrasing. A bare
  "toggle" means flip whatever Step 2 finds. A pure status question ("is STE
  on?") means report and stop — change nothing, and skip the confirmation
  below.
- **There is no default scope.** Ask which settings file to write, and don't
  read or edit anything until the user answers:
  - **user** — `~/.claude/settings.json`, applies everywhere.
  - **project** — `.claude/settings.local.json` in the current repo, applies
    here only and isn't checked in.

  If the invocation already named a scope ("just for this project"), don't
  re-ask — state the exact file path you're about to edit and get a yes.

## Step 2 — read the current state

Read the confirmed settings file and note the current `outputStyle` value (the
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
- Don't edit enterprise/managed policy files, and don't edit
  `.claude/settings.json` — that one is checked in, so it would push an output
  style onto everyone who clones the repo. Project scope means
  `settings.local.json`.
- Don't pick a scope on the user's behalf, and don't fall back to user scope
  when the answer is unclear — ask again.
- Don't run `/clear` or restart anything on the user's behalf.
- Don't reformat, reorder, or "clean up" the rest of the settings file.
