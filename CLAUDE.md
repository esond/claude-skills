# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## What this repo is

A Claude Code **plugin marketplace** (`claude-skills`) that publishes Eric's
personal skills as four independently toggleable plugins, one per bucket:

- `eng` — writing software: planning workflows, code review, git history,
  .NET hygiene, system design, repo docs.
- `comms` — external communications and human-facing writing.
- `behavior` — tweaks to Claude's behavior or Claude Code configuration.
- `docs` — documentation: Diátaxis-guided writing and auditing of tutorials,
  how-to guides, reference, and explanation.

There is no build, no tests, no runtime — Claude Code consumes the repo
directly by reading the manifest JSON and skill markdown files.

## Choosing a bucket for new content

Every skill, command, output style, hook, or agent belongs to exactly one
plugin. When adding one and the user hasn't said which plugin it goes in,
suggest a bucket from the four above and confirm before proceeding. If it
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
under a "Hooks" subsection in the plugin's `README.md` section — `behavior`
already has one, so create the subsection only for a plugin that doesn't. A
hook that changes Claude's
behavior should be opt-in and reversible from the skill that owns it, so the
hook stays inert until the user turns it on.

When adding or removing an output style, add the file under the owning
plugin's `output-styles/`, update that plugin's output styles table in
`README.md`, and bump the shared `version` as you would for a skill.
There is no manifest entry for the style itself to keep in sync.

The two Simplified Technical English styles are the one exception to
"styles are independent files". An output style has no include mechanism — the
file goes into the system prompt verbatim — so `simplified-technical-english.md`
and `simplified-technical-english-with-insights.md` carry byte-identical
`## The rules` and `## Do not lose the answer` sections by hand, and CI fails
when either one diverges. Edit a shared rule in both files, or the two flavors
end up enforcing different rules. Their `## Scope` sections differ on purpose
(the insights style names insight blocks), so that section is outside the check.

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
`name` and `description` with `name` matching its directory, and that the two
Simplified Technical English styles still share identical `## The rules` and
`## Do not lose the answer` sections. Run the same structural checks locally with
`claude plugin validate plugins/<plugin>/.claude-plugin/plugin.json` per
plugin, which also covers `hooks/hooks.json` syntax. `claude plugin validate`
does not cover the STE rules check — that one only runs in CI.

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
