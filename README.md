# claude-skills

Eric's personal [Claude Code](https://claude.ai/code) plugin marketplace. It
publishes five plugins — `eng`, `comms`, `behavior`, `docs`, and `esond` — so
each bucket can be toggled on and off independently, per project or context.

| Plugin                        | Bucket                                                                              |
| ----------------------------- | ----------------------------------------------------------------------------------- |
| [`eng`](plugins/eng)          | Writing software: planning, review, git history, .NET hygiene, design, repo docs.   |
| [`comms`](plugins/comms)      | External communications and human-facing writing.                                   |
| [`behavior`](plugins/behavior) | Tweaks to Claude's behavior and Claude Code configuration.                          |
| [`docs`](plugins/docs)        | Documentation: Diátaxis-guided writing and auditing of docs.                        |
| [`esond`](plugins/esond)      | Personal to Eric: how he writes and works, not a general-purpose workflow.          |

## Installation

Run these inside Claude Code:

```text
/plugin marketplace add esond/claude-skills
/plugin install eng@claude-skills
/plugin install comms@claude-skills
/plugin install behavior@claude-skills
/plugin install docs@claude-skills
/plugin install esond@claude-skills
```

The first line registers this repo as a marketplace; the rest install plugins
from it. Install only the ones you want.

## Updating

```text
/plugin marketplace update claude-skills
```

## Managing

Each plugin toggles independently:

```text
/plugin disable eng@claude-skills
/plugin enable eng@claude-skills
/plugin uninstall eng@claude-skills
```

## `eng` — engineering

### Skills

| Skill                                                                        | What it does                                                                                                                                                                                                 |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`clean-unused-cpm-packages`](plugins/eng/skills/clean-unused-cpm-packages/SKILL.md) | Removes unused `<PackageVersion>` entries from `Directory.Packages.props` files in a .NET CPM repo by scanning every `.csproj`/`.props`/`.targets` for `PackageReference` includes, then verifies via `dotnet restore`. |
| [`inline-review`](plugins/eng/skills/inline-review/SKILL.md)                 | Finds and addresses inline code-review comments left in the code, marked with a `rev:` prefix (`// rev:`, `# rev:`, etc.) — treats each like a GitHub review comment, makes the change or answers the question, then removes the ones it handled. |
| [`plan-repl`](plugins/eng/skills/plan-repl/SKILL.md)                         | Research → plan → annotate → implement workflow for non-trivial tasks. Writes research and a plan to `tasks/{name}/`, iterates on the plan via inline `> NOTE:` blockquotes until approved, then implements. |
| [`plan-repl-auto`](plugins/eng/skills/plan-repl-auto/SKILL.md)               | Automated multi-model variant of `plan-repl`: a coordinator fans research out to parallel Sonnet subagents (via the Workflow tool), synthesizes `plan.md` on the session model, then a Fable arbiter grills the plan over up to three bounded rounds until it has no substantive objections — a cheap→mid→expensive cascade that replaces the human `> NOTE:` loop. Explicit-only via [`/eng:plan-repl-auto`](plugins/eng/commands/plan-repl-auto.md); `--implement` runs the whole cascade autonomously (no human checkpoints) and fans out Sonnet subagents to build the plan, `--arbiter` overrides the arbiter model. Synthesis runs on the session model (`/model opus`). |
| [`plan-repl-resume`](plugins/eng/skills/plan-repl-resume/SKILL.md)           | Resumes an in-progress `plan-repl` task by reading its persisted files and cross-referencing with branch state to infer the current phase, then hands off to the right `plan-repl` phase to continue.        |
| [`pr-review-resolver`](plugins/eng/skills/pr-review-resolver/SKILL.md)       | Fetches unresolved GitHub PR review threads, submitted review bodies, and general comments, fixes each in code, commits, replies with the commit hash, and resolves the threads.                             |
| [`reorganize-branch-commits`](plugins/eng/skills/reorganize-branch-commits/SKILL.md) | Rewrites a non-default branch's history into clean, logical commits — proposes groupings from the actual diffs, gets approval, backs up, then rebuilds via `git reset` + re-commit (or scripted `git rebase -i`) with re-signing and hooks run.  |
| [`righting-software-system-design`](plugins/eng/skills/righting-software-system-design/SKILL.md) | Heavyweight, opt-in, interview-driven system design session faithful to Juval Löwy's *Righting Software*. Walks framing → use cases → interrogative volatility analysis → iDesign component mapping (Manager/Engine/ResourceAccess/Utility) → call-chain validation, surfacing unknown-unknowns along the way and producing a written recommendation report. |
| [`sign-unsigned-commits`](plugins/eng/skills/sign-unsigned-commits/SKILL.md) | Retroactively signs unsigned commits on the current branch that were authored by the current git user, via a targeted rebase that only amends matching commits.                                              |
| [`sync-core-repo-docs`](plugins/eng/skills/sync-core-repo-docs/SKILL.md)     | Creates or audits a repo's three core doc files — README.md, CLAUDE.md, REVIEW.md — in that dependency order. Missing files are generated from the codebase; existing files are audited for accuracy and fixed after confirmation. README is checked for effective newcomer orientation, CLAUDE.md defers to `/init`/`claude-md-improver`, and REVIEW.md holds reviewer guidance kept distinct from CLAUDE.md. |

Each skill's `description` field enumerates the natural-language phrases that
trigger it — you don't invoke them by name, Claude picks them up from how you
phrase the request.

### Commands

Commands are invoked by name as `/eng:<command>`, with explicit flag
arguments — a deterministic counterpart to skills' natural-language triggering.

| Command                                                          | What it does                                                                                                                                                                          |
| ----------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`/eng:sync-core-docs`](plugins/eng/commands/sync-core-docs.md)  | Thin wrapper over the [`sync-core-repo-docs`](plugins/eng/skills/sync-core-repo-docs/SKILL.md) skill. Accepts `--readme`, `--claude`, `--review` (they combine; no flags runs all three) and hands off to the skill. |
| [`/eng:plan-repl-auto`](plugins/eng/commands/plan-repl-auto.md)  | Runs the [`plan-repl-auto`](plugins/eng/skills/plan-repl-auto/SKILL.md) multi-model plan cascade. Takes the planning task plus `--implement` and `--arbiter <model>`, and routes them to the skill. |

## `comms` — communications

| Skill                                                       | What it does                                                                                                                                                                                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`dehumanizer`](plugins/comms/skills/dehumanizer/SKILL.md)  | Makes a message look AI-generated — the inverse of [the `humanizer`](https://github.com/blader/humanizer), a separate external skill. Injects LLM "tells" (em dashes, rule of three, copula avoidance, AI vocabulary, emoji bold headers) while preserving both the original meaning and its mood, on an intensity dial (`subtle` default, `heavy`, `unhinged`). Mostly for trolling. |

## `behavior` — agent behavior

### Skills

| Skill                                                                          | What it does                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`bro`](plugins/behavior/skills/bro/SKILL.md)                                  | Restates Claude's last message in plain, jargon-free language. Explicit-only (`disable-model-invocation: true`) — invoked by name, not auto-triggered.                                                      |
| [`permission-consolidator`](plugins/behavior/skills/permission-consolidator/SKILL.md) | Reviews a Claude Code `settings.json` allow list, proposes consolidations for `Bash(...)` entries that share a command prefix, and flags one-off or stale entries for pruning.                               |
| [`toggle-simplified-english`](plugins/behavior/skills/toggle-simplified-english/SKILL.md) | Enables, disables, toggles, or swaps the flavor of the Simplified Technical English output style by editing the `outputStyle` key in Claude Code settings, instead of hand-editing JSON. Two flavors ship — plain STE and STE with Insights — and words like "insights" or "explanatory" select the second; plain is the default. Explicit-only (`disable-model-invocation: true`) — run it as `/behavior:toggle-simplified-english`, since it writes to a settings file. Confirms which scope to write (user or project-local) before touching anything. |

### Output styles

An [output style](https://code.claude.com/docs/en/output-styles) appends its
instructions to Claude Code's system prompt, so it shapes every response instead
of firing on a trigger phrase. Only one can be active at a time, and it replaces
whichever built-in style you were on. Both styles here set
`keep-coding-instructions: true`, which the docs recommend when you are changing
how Claude communicates but still want it coding the same way. Neither sets
`force-for-plugin`, which would override your own `outputStyle` setting for
anyone with the plugin enabled.

| Output style                                                                            | What it does                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`Simplified Technical English`](plugins/behavior/output-styles/simplified-technical-english.md) | Shapes every message Claude sends with ASD-STE100 Simplified Technical English: short sentences, active voice, simple tenses and plain modals, one meaning per word, no idioms. Scoped to transcript prose only — never code, commits, PR comments, file contents, drafts for other people, or Claude's own thinking. Sets `keep-coding-instructions: true`, so Claude Code's software-engineering system prompt loads exactly as it does under the Default style. |
| [`Simplified Technical English with Insights`](plugins/behavior/output-styles/simplified-technical-english-with-insights.md) | The same STE rules, plus the `★ Insight` educational callouts from Claude Code's built-in **Explanatory** style. Only one output style can be active, so the two behaviours are merged at authoring time rather than layered at runtime. The two sources conflict — Explanatory relaxes length limits, STE tightens them — so the file resolves it explicitly: STE governs *how* every sentence is written, Explanatory governs *what extra content* appears, and insight blocks obey the sentence rules like everything else. The insight behaviour is copied from the built-in as of Claude Code 2.1.222, so re-check it after CLI upgrades. |

Turn one on with `/config` → **Output style**, set it in
`~/.claude/settings.json` to apply it everywhere, or run
[`/behavior:toggle-simplified-english`](plugins/behavior/skills/toggle-simplified-english/SKILL.md),
which edits the setting for you after confirming the scope. A plugin output
style is registered as `<plugin>:<name>`, so the value is namespaced:

```json
"outputStyle": "behavior:Simplified Technical English"
```

Either way it takes effect on the next `/clear` or new session. Edits to the
style file also need `/reload-plugins` (or a restart) — unlike `SKILL.md` edits,
which apply immediately.

The Simplified Technical English style is unofficial, and it is not endorsed by
ASD or STEMG. The Part 2 dictionary is copyrighted, so the style applies the
rules and public examples only.

### Hooks

| Hook                                                         | When it fires                    | What it does                                                                                                                                          |
| ------------------------------------------------------------ | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`reinforce-ste.sh`](plugins/behavior/hooks/reinforce-ste.sh) | `UserPromptSubmit`               | Injects a ~26-token reminder of the STE rules that drift first, restoring parity with what built-in output styles get for free (see below).            |
| [`reinforce-ste.sh`](plugins/behavior/hooks/reinforce-ste.sh) | `SessionStart`, source `compact` | Injects a longer ~100-token reminder. Compaction deletes every compliant turn, and those examples are a large part of what holds the voice.            |

**Why this hook exists.** The
[output styles doc](https://code.claude.com/docs/en/output-styles#how-output-styles-work)
states that "all output styles trigger reminders for Claude to adhere to the
output style instructions during the conversation." In Claude Code 2.1.222 that
does not happen for plugin or user styles.

Two limitations stack. First, the reminder *is* queued for every non-default
style, and the resolver does return the full registry with custom styles
included — but the step that renders the reminder looks the display name up in a
map holding only the built-ins (`default`, `Proactive`, `Explanatory`,
`Learning`) and returns nothing when the lookup misses. A plugin style registers
as `<plugin>:<name>`, so it always misses. The registry merge builds a shallow
copy of that map and adds custom styles to the copy, so the original is never
extended.

Second, a custom style has no reminder text of its own to render even if the
lookup succeeded. The frontmatter schema is `.strict()` and accepts only `name`,
`description`, `keep-coding-instructions`, and `force-for-plugin`. There is no
`turn-reminder` key, and an unknown key does not get ignored — strict validation
rejects it and the style fails to load.

The practical effect: a built-in style gets re-anchored every single turn, and a
custom style gets re-anchored never. The system prompt is its only carrier, and
recency erodes it as the context fills. That is the drift this hook fixes.

**Re-check this after CLI upgrades.** The name lookup reads like a narrow bug
rather than a design decision, since the resolved style object was available one
call upstream. If a later version fixes it, custom styles will get the generic
fallback sentence — not tailored text, because of the second limitation — so this
hook's per-turn arm becomes partly redundant and the `compact` arm still earns
its place.

**Gating.** The hook reads `outputStyle` from `.claude/settings.local.json`,
then `.claude/settings.json`, then `$CLAUDE_CONFIG_DIR/settings.json` (default
`~/.claude`), and stays silent unless the first value it finds is one of the two
STE styles. So
[`/behavior:toggle-simplified-english`](plugins/behavior/skills/toggle-simplified-english/SKILL.md)
turns the reinforcement on and off along with the style, and there is no second
switch. It needs `jq` on `PATH`, and it exits 0 on every path — a hook failure
must never block a turn or session startup.

Those three files are the scopes the toggle skill can write, but they are not
Claude Code's whole precedence chain: an enterprise managed-settings file
outranks all of them. The hook does not read it, since its path is
platform-specific and the case is rare. If an admin pins `outputStyle` to a
non-STE style while your user settings still name an STE one, the hook keeps
injecting reminders for a style that isn't active. Clear the user-level setting
to stop it.

**Cost and caching.** Hooks
[never invalidate the prompt cache](https://code.claude.com/docs/en/prompt-caching#enabling-or-disabling-a-plugin)
— what they add is appended after the existing conversation, so the next request
pays for the new content and still reads everything before it from cache. So the
per-turn injection costs tokens but never triggers a re-read.

The reminder does accumulate in the conversation layer, so turn 40 carries 40
copies: ~1,000 tokens at 40 turns, nearly all of it billed at the
[cache read rate](https://code.claude.com/docs/en/prompt-caching#check-cache-performance).
The per-turn text is kept terse for that reason — the full spec is already in the
system prompt, so the reminder only re-anchors the rules that slip first.

Trimming the style file saves ~400 tokens per request, but those were mostly
cache reads at roughly a tenth of the input rate, so the two changes are closer
to a wash on cost than the raw token counts suggest. The shrink was worth making
for adherence, not for the tokens.

**Latency.** Because it fires per turn, process spawns dominate — each one costs
~35ms on Windows. The script holds itself to three on the normal path (`cat`,
one `jq` to read settings, one `jq` to emit); event and source detection use
shell `case` globs, and a fourth spawn appears only when `CLAUDE_PROJECT_DIR` is
unset. Measured over 20 runs, net of harness overhead: ~111ms per turn when a
STE style is active, ~75ms on the early-exit path. That early-exit cost is paid
on every turn by anyone with the `behavior` plugin enabled, even under a non-STE
style, because the gate cannot be evaluated without reading settings. If you add
to this script, prefer a shell builtin over a subprocess.

Hook changes need `/reload-plugins` or a restart, like output styles.

## `docs` — documentation

Skills for writing and auditing documentation with the
[Diátaxis](https://diataxis.fr) methodology: every piece of content is one of
four kinds — tutorial, how-to guide, reference, or explanation — and most
documentation problems come from one document trying to serve two needs at
once. The `diataxis` router applies the compass and hands off to the right
type skill; the four type skills each carry the craft rules for their kind.

| Skill                                                                        | What it does                                                                                                                                                                                                 |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`diataxis`](plugins/docs/skills/diataxis/SKILL.md)                          | The router: classifies what the user wants to write with the Diátaxis compass (action/cognition × acquisition/application) and loads the matching type skill. With `--audit`, assesses existing docs against the model and proposes relocations/splits without rewriting content. |
| [`diataxis-explanation`](plugins/docs/skills/diataxis-explanation/SKILL.md)  | Writes or audits understanding-oriented discussion — architecture overviews, design rationale, concept docs. Consolidates the scattered "why", makes connections, admits opinion, keeps instruction and catalogs out. |
| [`diataxis-how-to`](plugins/docs/skills/diataxis-how-to/SKILL.md)            | Writes or audits goal-oriented directions — runbooks, recipes, troubleshooting guides for competent practitioners. Names the goal in the title, omits the unnecessary, links out to reference and explanation. |
| [`diataxis-reference`](plugins/docs/skills/diataxis-reference/SKILL.md)      | Writes or audits information-oriented technical description — API/CLI/config docs. Austere and consistent, structured to mirror the machinery, describing without instructing or opining.                     |
| [`diataxis-tutorial`](plugins/docs/skills/diataxis-tutorial/SKILL.md)        | Writes or audits learning-oriented lessons — getting-started and onboarding walkthroughs. Single reliable path, visible results at every step, ruthlessly minimized explanation.                              |

## `esond` — personal

Skills that encode how Eric specifically writes and works. Everything else in
this marketplace is meant to be useful to anyone; this bucket is not. Enable it
only where output should sound like him.

### Skills

| Skill                                                                              | What it does                                                                                                                                                                                                 |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`conversational-voice`](plugins/esond/skills/conversational-voice/SKILL.md)       | Writes Eric's side of a conversation with another person — Slack, DMs, email, PR and review comments — in his own voice. Direct, casual, brief but complete, and stripped of the tells that give away an AI draft (em dashes, rule of three, corporate vocabulary, hedged asks, punchy closers). Applies to turns in an exchange, not to artifacts he authors like PR descriptions or commit messages. |
| [`work-item-voice`](plugins/esond/skills/work-item-voice/SKILL.md)                 | Writes issues in Eric's voice for any tracker — Jira, Linear, GitHub Issues — across the three kinds: features, tasks, and bugs. Never prescribes the implementation, so the developer keeps room to solve it. Features get behavior-driven framing (the "imagine it's 1922" test) with concrete domain detail; bugs get what happened / what was expected / how to see it. Language is written for non-native readers, and a sentence stays only if a developer needs it to start. Drafts by default and files only on request, behind a confirmation gate. |

### Shared references

Both voice skills read
[`references/writing-for-people.md`](plugins/esond/references/writing-for-people.md)
before they draft. It holds the rules that are not specific to either one — the
writer pays the compression cost, and how to hand the draft back. A third voice
skill loads the same file rather than restating them.
