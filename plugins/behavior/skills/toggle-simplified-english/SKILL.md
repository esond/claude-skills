---
name: toggle-simplified-english
description: >-
  Enable, disable, toggle, or swap the flavor of the Simplified Technical
  English (STE) output style by editing the `outputStyle` key in Claude Code
  settings — no manual JSON editing. Two flavors ship: plain STE, and STE with
  Insights (adds the `★ Insight` callouts from the built-in Explanatory style).
  Plain is the default; words like "insights", "explanatory", or "educational"
  select the other. Explicit-only: invoked by name, never auto-triggered,
  because it writes to a settings file.
disable-model-invocation: true
---

# toggle-simplified-english

Flips the `outputStyle` setting between `behavior:Simplified Technical
English` and the default, editing the settings JSON so the user doesn't have
to. The style itself ships in this same plugin, so if this skill ran, the
style is installed.

## The two flavors

This plugin ships **two** STE styles, so every enable has to pick one:

| Flavor       | `outputStyle` value                                        | What it adds                                                                  |
| ------------ | ---------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **plain**    | `behavior:Simplified Technical English`                     | The prose rules alone. The default.                                           |
| **insights** | `behavior:Simplified Technical English with Insights`       | The same rules plus `★ Insight` callouts, from the built-in Explanatory style. |

Pick from the user's own words. **Plain is the default** — choose it whenever
nothing in the request points at insights.

Signals for **insights**: "with insights", "insights", "insight blocks",
"explanatory", "explanatory mode", "STE+insights", "the explanatory one", "the
one with the stars", "explain as you go", "educational", "teach me as you work",
"tell me why you did that".

Signals for **plain**: "STE", "simplified technical english", "the normal one",
"plain", "just the rules", "no insights", "without the insights", "quiet",
"terse".

Two cases that are not a plain enable:

- **A flavor swap.** If STE is already on and the user names the other flavor
  ("switch to insights", "drop the insights"), that is one write to
  `outputStyle`, not a disable followed by an enable. Say which flavor you
  moved from and to.
- **A bare "toggle" or "turn it off".** Flavor does not matter. Disabling
  removes the key whichever flavor was set.

If the request implies a flavor change but you cannot tell which one, ask. Do
not guess between the two.

This setting is also the on/off switch for the plugin's `reinforce-ste.sh`
hook, which re-states the STE rules each turn and again after a compaction.
The hook reads `outputStyle` from the same three files in the same precedence
order and stays silent unless the value is exactly one of the two names above.
So enabling either style enables the reinforcement, and disabling it makes the
hook inert — there is no second switch to set.

## Step 1 — work out the intent, then confirm the scope

- **Enable**, **disable**, **toggle**, or **swap flavor** from the user's
  phrasing. A bare "toggle" means flip whatever Step 2 finds. A pure status
  question ("is STE on?") means report and stop — change nothing, name which
  flavor is set, and skip the confirmation below.
- **If you are enabling or swapping, pick the flavor now**, using the signals
  in "The two flavors" above. Carry that choice into Step 2 and Step 3.
- **There is no default scope.** Ask which settings file to write, and don't
  read or edit anything until the user answers:
  - **user** — `~/.claude/settings.json`, applies everywhere. If
    `CLAUDE_CONFIG_DIR` is set, user scope is that directory's
    `settings.json` instead, so check the variable before naming the path.
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
- `outputStyle` holds the **other STE flavor** and you are enabling: this is a
  flavor swap. Write the new value, and don't warn about replacing a style.
- `outputStyle` holds some **other non-STE** style and you are enabling: only
  one output style can be active. Tell the user what it would replace and get a
  yes before proceeding.
- Already set to the **exact flavor** requested: say so and stop. Don't rewrite
  the file. Compare the full value, not just whether STE is on — plain and
  insights are different states.

## Step 3 — make the edit

Preserve every other key and the file's existing formatting; touch only
`outputStyle`.

- **Enable** or **swap flavor**: set `"outputStyle"` to the flavor you picked in
  Step 1. Copy the value exactly from the table above — the two names differ
  only by the ` with Insights` suffix, and a near-miss leaves the style
  unresolved and the hook inert. If the file doesn't exist, create it containing
  just that key.
- **Disable**: remove the `outputStyle` key entirely, which falls back to the
  default style (or whatever a lower-precedence scope sets).

## Step 4 — report

State what changed (old value → new value, and in which file) and remind the
user it takes effect on the next `/clear` or new session — the current
session keeps its already-built system prompt.

If you just enabled a style, name which of the two you wrote, and mention that
the `reinforce-ste.sh` reinforcement hook now applies. If the user never
enabled this plugin's hooks in a prior session, that hook needs
`/reload-plugins` or a restart before it fires, unlike the settings change
itself.

## Things not to do

- Don't touch any settings key other than `outputStyle`.
- Don't edit enterprise/managed policy files, and don't edit
  `.claude/settings.json` — that one is checked in, so it would push an output
  style onto everyone who clones the repo. Project scope means
  `settings.local.json`.
- Don't pick a scope on the user's behalf, and don't fall back to user scope
  when the answer is unclear — ask again.
- Don't guess between the two flavors. Plain is the default when nothing points
  at insights, but if the request implies a flavor change and you can't tell
  which, ask.
- Don't run `/clear` or restart anything on the user's behalf.
- Don't reformat, reorder, or "clean up" the rest of the settings file.
