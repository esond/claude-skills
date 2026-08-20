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

## Vendored skills

A few skills here were written by someone else. They are copied in rather than
rewritten, and they keep their original author's copyright.

| Skill                | Plugin     | Upstream                                                                                                             |
| -------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------- |
| `grill-me`           | `eng`      | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me) — MIT © Matt Pocock  |
| `grilling`           | `eng`      | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling) — MIT © Matt Pocock  |
| `writing-for-agents` | `behavior` | [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/writing-for-agents) — MIT © Matt Pocock |

[mattpocock/skills](https://github.com/mattpocock/skills) is a larger, opinionated
set that installs as a whole. These three are the ones worth having here, so they
are borrowed individually instead.

Each is a byte-for-byte copy of upstream with one exception: `grill-me`'s body
calls `eng:grilling` rather than `grilling`, because a skill shipped inside a
plugin is namespaced. That change is recorded in the manifest so a sync never
reverts it.

Full license text lives in the `NOTICE` file at the root of the plugin that
carries the skill — [`plugins/eng/NOTICE`](plugins/eng/NOTICE) and
[`plugins/behavior/NOTICE`](plugins/behavior/NOTICE).

### Keeping them in sync

[`vendor/UPSTREAM.json`](vendor/UPSTREAM.json) records each source repo, the
commit last pulled from it, the upstream → local path map, the files to ignore,
and any deliberate local change.

```sh
sh scripts/sync-vendored.sh           # what changed upstream? exits 1 on drift
sh scripts/sync-vendored.sh --apply   # pull it in and record the new commit
```

The check diffs upstream between the recorded commit and its current head, so it
reports the actual upstream change rather than just "these files differ".
`--apply` copies the new files and rewrites the recorded commit, but skips every
file listed under `deltas` — it prints their upstream diff instead, so a
deliberate local change is ported by hand rather than silently reverted.

Each delta carries its own `synced` commit, and `--apply` never advances it.
That is what keeps an unported change from disappearing: the delta file is
always diffed from its own baseline, so it keeps reporting on every run until
someone ports the change and moves that baseline forward by hand. Without it,
one `--apply` would rewrite the source commit and the change would drop out of
the next report unnoticed.

Working in this repo with Claude Code, `/sync-vendored` drives the same script
and walks the results.

## `eng` — engineering

### Skills

| Skill                                                                        | What it does                                                                                                                                                                                                 |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`clean-unused-cpm-packages`](plugins/eng/skills/clean-unused-cpm-packages/SKILL.md) | Removes unused `<PackageVersion>` entries from `Directory.Packages.props` files in a .NET CPM repo by scanning every `.csproj`/`.props`/`.targets` for `PackageReference` includes, then verifies via `dotnet restore`. |
| [`grill-me`](plugins/eng/skills/grill-me/SKILL.md)                           | Explicit-only (`disable-model-invocation: true`) entry point that hands off to `grilling`. Type it when you want the interview and don't want to wait for Claude to offer one. **[Vendored](#vendored-skills)** from [mattpocock/skills](https://github.com/mattpocock/skills). |
| [`grilling`](plugins/eng/skills/grilling/SKILL.md)                           | Interviews you about a plan, decision, or idea until you reach a shared understanding. Models the work as a design tree and asks it in rounds: every question whose prerequisites are already settled goes out together, each with a recommended answer, and your answers push the frontier outward. Looks up facts itself rather than asking you for them; the decisions stay yours. **[Vendored](#vendored-skills)** from [mattpocock/skills](https://github.com/mattpocock/skills). |
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
| [`de-slop`](plugins/comms/skills/de-slop/SKILL.md)  | Deep-strips AI tells (claudisms) from a draft while preserving its meaning and the writer's voice — the inverse of `dehumanizer`. Sweeps the draft against a bundled snapshot of the living [claudisms banlist](https://claudisms.ai/claudisms.md), catches the constructions a text search misses, then re-sweeps its own rewrites. For writing that ships under your name. |
| [`dehumanizer`](plugins/comms/skills/dehumanizer/SKILL.md)  | Makes a message look AI-generated — the inverse of [the `humanizer`](https://github.com/blader/humanizer), a separate external skill. Injects LLM "tells" (em dashes, rule of three, copula avoidance, AI vocabulary, emoji bold headers) while preserving both the original meaning and its mood, on an intensity dial (`subtle` default, `heavy`, `unhinged`). Mostly for trolling. |

## `behavior` — agent behavior

### Skills

| Skill                                                                          | What it does                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`bro`](plugins/behavior/skills/bro/SKILL.md)                                  | Restates Claude's last message in plain, jargon-free language. Explicit-only (`disable-model-invocation: true`) — invoked by name, not auto-triggered.                                                      |
| [`permission-consolidator`](plugins/behavior/skills/permission-consolidator/SKILL.md) | Reviews a Claude Code `settings.json` allow list, proposes consolidations for `Bash(...)` entries that share a command prefix, and flags one-off or stale entries for pruning.                               |
| [`writing-for-agents`](plugins/behavior/skills/writing-for-agents/SKILL.md)    | Reference for writing anything an agent reads — a skill, an `AGENTS.md`/`CLAUDE.md`, a doc behind a pointer. Covers context pointers and how their wording decides when material gets reached, the context/cognitive load tradeoff, the information hierarchy and progressive disclosure, completion criteria, leading words, and pruning for no-ops and duplication. [`SKILL-MECHANICS.md`](plugins/behavior/skills/writing-for-agents/SKILL-MECHANICS.md) adds the skill-specific part: frontmatter, model- vs user-invocation, and router skills. **[Vendored](#vendored-skills)** from [mattpocock/skills](https://github.com/mattpocock/skills). |

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
| [`work-item-voice`](plugins/esond/skills/work-item-voice/SKILL.md)                 | Writes issues in Eric's voice for any tracker — Jira, Linear, GitHub Issues — across the three kinds: features, tasks, and bugs. Never prescribes the implementation, so the developer keeps room to solve it. Features get behavior-driven framing (the "imagine it's 1922" test) with concrete domain detail; bugs get what happened / what was expected / how to see it. Language is written for non-native readers, and a sentence stays only if a developer needs it to start. Also covers editing an issue that already exists — inherit the voice, re-read the whole body after an append, and expect the tracker to rewrite your markdown. Drafts by default; filing a new issue is gated on confirmation, an edit at explicit request is not. |

### Shared references

Both voice skills read
[`references/writing-for-people.md`](plugins/esond/references/writing-for-people.md)
before they draft. It holds the rules that are not specific to either one — the
writer pays the compression cost, and how to hand the draft back. Any voice
skill added later reads the same file rather than restating the rules.
