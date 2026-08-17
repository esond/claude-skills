# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## What this repo is

A Claude Code **plugin marketplace** (`claude-skills`) that publishes Eric's
personal skills as five independently toggleable plugins, one per bucket:

- `eng` — writing software: planning workflows, code review, git history,
  .NET hygiene, system design, repo docs.
- `comms` — external communications and human-facing writing.
- `behavior` — tweaks to Claude's behavior or Claude Code configuration.
- `docs` — documentation: Diátaxis-guided writing and auditing of tutorials,
  how-to guides, reference, and explanation.
- `esond` — personal to Eric: how he writes and works. Anything tuned to him
  rather than useful to anyone belongs here.

There is no build, no tests, no runtime — Claude Code consumes the repo
directly by reading the manifest JSON and skill markdown files.

## Choosing a bucket for new content

Every skill, command, output style, hook, or agent belongs to exactly one
plugin. When adding one and the user hasn't said which plugin it goes in,
suggest a bucket from the five above and confirm before proceeding. If it
genuinely fits none of them, propose creating a new plugin bucket (new
directory under `plugins/`, new `plugin.json`, new marketplace entry) rather
than forcing a bad fit — the whole point of the split is that buckets toggle
independently per context. A new bucket starts at the version the other
plugins are already on, not at `0.1.0`; CI rejects a plugin that disagrees.

A command must live in the same plugin as the skill it wraps, and skills that
hand off to each other (the `plan-repl` family) must stay in one plugin.

## Manifest layout

These files drive discovery; changing one without the others will break
loading:

- `.claude-plugin/marketplace.json` — declares the marketplace and lists its
  plugins. Each plugin entry has `name`, `source` (relative path to plugin
  root, e.g. `./plugins/eng`), `description`, `version`.
- `plugins/<plugin>/.claude-plugin/plugin.json` — declares one plugin. `skills`
  is an array of paths (relative to the plugin root) to skill directories;
  `agents` (optional) is an array of paths to bundled subagent definition
  files. `name` and `version` must match the corresponding marketplace entry,
  and every plugin carries the *same* `version` — see below.
- `plugins/<plugin>/skills/<skill-name>/SKILL.md` — the skill. One per
  directory. The directory name is the skill name.
- `plugins/<plugin>/commands/<name>.md` — a slash command, auto-discovered at
  the plugin root, so `plugin.json` does not list it. Invoked as
  `/<plugin>:<name>` (e.g. `/eng:plan-repl-auto`) — the namespace is the
  plugin name, so moving a command between plugins renames it.
- `plugins/<plugin>/agents/<name>.md` — a subagent bundled for a skill to
  spawn. Frontmatter sets its `name`, `description`, `tools`, and a pinned
  `model`; the file body is the agent's prompt. Listed in that plugin's
  `plugin.json` under `agents`, and invoked by a skill via `subagent_type`
  rather than by the user.
- `plugins/<plugin>/hooks/hooks.json` — event handlers, auto-discovered at the
  plugin root, so `plugin.json` does not list them. Scripts live beside it in
  `hooks/` and are invoked via `${CLAUDE_PLUGIN_ROOT}`. A hook fires for every
  session the plugin is enabled in, so it must exit 0 on all failure paths
  rather than block startup. Write them in POSIX `sh` (Git Bash runs them on
  Windows); `.gitattributes` pins `*.sh` to LF, since CRLF survives Git Bash
  but breaks dash.
- `plugins/<plugin>/output-styles/<name>.md` — an output style,
  auto-discovered at the plugin root, so `plugin.json` does not list it. (An
  `outputStyles` manifest key *replaces* the default scan rather than adding
  to it, so pointing it anywhere but `./output-styles/` hides this directory.)
  Frontmatter sets `name`, `description`, and `keep-coding-instructions` —
  leave that last one `true` unless the style really means to drop Claude
  Code's software-engineering instructions. Do not set `force-for-plugin`: it
  applies the style to anyone with the plugin enabled, so the only way to turn
  it off becomes disabling every skill in that plugin along with it.
- `plugins/<plugin>/references/<name>.md` — prose shared by two or more skills
  in the same plugin, so a rule that is not specific to any one of them gets
  stated once. There is no manifest entry and no include mechanism, so each
  skill that needs it tells Claude to read the file. Give the path relative to
  the `SKILL.md` (`../../references/<name>.md`), then restate it as a
  plugin-root fragment so the read still resolves by search if the relative hop
  fails. CI checks that link from both ends — every path a skill names must
  resolve, and every reference must have at least one reader. That catches the
  rename. It cannot catch a read that fails at runtime, so also tell the skill
  to say so in one line when the read fails, rather than proceeding as if the
  shared rules had loaded. Do not make it stop — a stop-and-ask checkpoint is
  for a destructive action, not for a missing prose file. Use this only for
  content that genuinely spans skills. A reference used by one skill belongs in
  that skill's own `references/` directory instead.

When adding or removing a skill, update the owning plugin's `plugin.json`
(`skills` array) and — if the marketplace's surface area changed meaningfully
— bump the version. **The version is global**: one number shared by all
plugins, so bump it in every `plugins/*/.claude-plugin/plugin.json` and every
`marketplace.json` plugin entry at once, including the plugins that didn't
change. CI fails when they diverge, and a `v*` release tag must equal that
version. Also update that plugin's skills table in `README.md`: add the new
skill in alphabetical order with a one-line summary of what it does, or remove
the row on deletion.

When a skill bundles a subagent, add its file under the owning plugin's
`agents/`, list it in that plugin's `plugin.json` `agents` array, and add an
"Agents" subsection to the plugin's section in `README.md`.

When a skill bundles a hook, add the script under the owning plugin's
`hooks/`, register it in that plugin's `hooks/hooks.json`, and document it
under a "Hooks" subsection in the plugin's `README.md` section — no plugin has
one today, so create it. A hook that changes Claude's
behavior should be opt-in and reversible from the skill that owns it, so the
hook stays inert until the user turns it on.

When adding or removing an output style, add the file under the owning
plugin's `output-styles/`, add an "Output styles" table to that plugin's
`README.md` section, and bump the shared `version` as you would for a skill.
There is no manifest entry for the style itself to keep in sync. No plugin
ships an output style today.

## Vendored skills

Some skills are copied in from someone else's repo rather than written here.
They live in a normal plugin alongside the rest — nothing about the manifest
layout changes — but they are **not yours to edit freely**: a local change has
to survive every future sync, so it costs something to make one.

`vendor/UPSTREAM.json` is the record. Each source entry holds the upstream repo
and ref, the commit last pulled from it (`synced`), the upstream → local
directory pairs, the files to `exclude`, and the `deltas` — deliberate local
changes, each with the reason it exists.

`scripts/sync-vendored.sh` reads it. With no arguments it diffs upstream
between `synced` and its current head and exits 1 on drift, so it reports what
upstream actually changed rather than just which files differ. `--apply` copies
the new files in and rewrites `synced`, but skips every file named in `deltas`
and prints its upstream diff instead — a deliberate local change gets ported by
hand, never silently reverted. `/sync-vendored` (repo-local, in
`.claude/commands/`) drives the same script and walks the results.

Each delta entry carries its own `synced`, and `--apply` never advances it — a
delta file is diffed from that baseline rather than the source's. **After
porting an upstream change into a delta file, set that delta's `synced` to the
source's `synced`.** Until you do, the change keeps appearing in every report,
which is the point: the source commit moves on `--apply` whether or not anyone
ported the delta, so without a separate baseline an unported change would
silently drop out of the next run's diff.

When vendoring a new skill:

- Copy it byte for byte. Every edit becomes a permanent merge cost, so make one
  only when the skill is broken here otherwise — namespacing a cross-skill
  handoff is the usual case, since a skill shipped in a plugin is reached as
  `<plugin>:<skill>`.
- Record any such edit under `deltas` with its reason, or the next sync reverts
  it.
- Add its directory pair to `paths`, and `exclude` anything Claude Code does
  not read (`agents/openai.yaml` is OpenAI Codex interop metadata) so it never
  shows up as drift.
- Add a `NOTICE` file at the root of the owning plugin carrying the upstream
  license text and copyright, and list the skill in the README's "Vendored
  skills" table. The root `LICENSE` is MIT and points at those NOTICE files;
  vendored work stays under its own author's copyright.
- Mark the skill's README row so it reads as borrowed rather than written here.

Two known frictions with vendored content, both left alone on purpose:

- `writing-for-agents` argues for pruning a skill's description hard — one
  trigger per branch, synonyms collapsed. This repo's convention (below) is to
  enumerate trigger phrases, because terse descriptions miss matches. The
  disagreement is real, and it is about how far the model generalizes over
  surface phrasing. Resolve it this way, which is what this repo already does
  in practice:

  - **Enumerate branches. Sample synonyms.** A branch is a distinct situation
    the skill handles — a bug versus a feature, drafting versus editing an
    existing issue. Those must all be named, because they define the skill's
    scope. A synonym is one situation said differently ("file a bug" / "log a
    bug" / "report a bug"); two or three anchors spanning the register are
    enough, and the fourth is a no-op.
  - **Spell out vocabulary the name cannot carry.** `rev:` in `inline-review`,
    "CPM" in `clean-unused-cpm-packages` — the model cannot infer those. This is
    where verbosity is load-bearing and pruning breaks triggering.
  - **State the boundary once several skills could match.** The `diataxis`
    family names what belongs to a sibling instead. As the installed set grows,
    a description's job shifts from being findable to being distinguishable, and
    a wrong fire costs more than a missed one.

  Where they still disagree, this repo's convention wins for skills written
  here.
- `writing-for-agents` and `esond/references/writing-for-people.md` cover
  adjacent ground and neither should absorb the other. One is about an agent's
  context window and attention; the other is about a human reader. Keep them
  separate.

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
request and every push to `main`. It checks that the marketplace manifest and
every `plugins/*/.claude-plugin/plugin.json` parse, that each plugin's name and
version match its marketplace entry (and that every plugin directory is
listed), that all plugins carry the same version, that every path in a
plugin's `skills` array has a `SKILL.md`, that each skill's frontmatter carries
`name` and `description` with `name` matching its directory, and that every
shared reference path a skill names resolves and every shared reference has a
reader. Run the same structural checks locally with
`claude plugin validate plugins/<plugin>/.claude-plugin/plugin.json` per
plugin, which also covers `hooks/hooks.json` syntax. `claude plugin validate`
does not cover the shared-reference check — that one only runs in CI.

Nothing automated executes a skill, so behavior is still verified by hand:

1. Reload the plugins in Claude Code (via the marketplace).
2. Trigger the skill with a phrase from its `description` and confirm it runs.

Edits to a `SKILL.md` body apply immediately. Changes under a plugin's
`hooks/` and `output-styles/` do not — run `/reload-plugins` or restart. An
output style is also read once when the system prompt is built, so a change to
it needs `/clear` or a new session on top of the reload.

If the skill doesn't fire, the `description` is usually the problem — not the
body.

## Conventions worth preserving

- Skill descriptions are verbose and enumerate trigger phrases. Resist the urge
  to tighten them — terse descriptions miss matches.
- Skills that rewrite history, push, or otherwise take destructive actions must
  require explicit user confirmation at the relevant step. The existing skills
  model this carefully; match that style when adding new ones.
