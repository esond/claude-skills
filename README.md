# skills

Eric's personal skills for [Claude Code](https://claude.ai/code), Codex, and
other coding agents. They ship as five independently installable plugins —
`eng`, `comms`, `behavior`, `docs`, and `esond` — so each bucket can be
toggled on and off independently, per project or context.

| Plugin                        | Bucket                                                                              |
| ----------------------------- | ----------------------------------------------------------------------------------- |
| [`eng`](plugins/eng)          | Writing software: planning, review, git history, .NET hygiene, design, repo docs.   |
| [`comms`](plugins/comms)      | External communications and human-facing writing.                                   |
| [`behavior`](plugins/behavior) | Tweaks to the agent's behavior: output shaping.                                    |
| [`docs`](plugins/docs)        | Documentation: Diátaxis-guided writing and auditing of docs.                        |
| [`esond`](plugins/esond)      | Personal to Eric: how he writes and works, not a general-purpose workflow.          |

## Installation

Two routes, depending on the agent. Pick one; installing through both leaves
two copies of each skill.

<details>
<summary><strong>Claude Code</strong></summary>

From a terminal:

```sh
claude plugin marketplace add esond/skills
claude plugin install eng@esond
claude plugin install comms@esond
claude plugin install behavior@esond
claude plugin install docs@esond
claude plugin install esond@esond
```

The same commands work inside a Claude Code session as `/plugin marketplace add
esond/skills`, `/plugin install eng@esond`, and so on.

The first line registers this repo as a marketplace; the rest install plugins
from it. Install only the ones you want.

</details>

<details>
<summary><strong>Codex and other agents</strong></summary>

Install every skill with the [skills.sh](https://skills.sh) CLI:

```sh
npx skills@latest add esond/skills
```

Or one bucket at a time:

```sh
npx skills@latest add esond/skills/plugins/eng
npx skills@latest add esond/skills/plugins/comms
npx skills@latest add esond/skills/plugins/behavior
npx skills@latest add esond/skills/plugins/docs
npx skills@latest add esond/skills/plugins/esond
```

Codex can also subscribe to the repo as a plugin marketplace with
`codex plugin marketplace add esond/skills`, then install buckets from
`/plugins` inside a Codex session.

</details>

## Updating

Claude Code:

```text
/plugin marketplace update esond
```

skills.sh:

```sh
npx skills update
```

## Managing

Each plugin toggles independently in Claude Code:

```text
/plugin disable eng@esond
/plugin enable eng@esond
/plugin uninstall eng@esond
```

A skills.sh install is plain files under `.agents/skills/` (or
`.claude/skills/`); delete a skill's directory to remove it.

## `eng` — engineering

### Skills

| Skill                                                                        | What it does                                                                                                                                                                                                 |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`clean-unused-cpm-packages`](plugins/eng/skills/clean-unused-cpm-packages/SKILL.md) | Removes unused `<PackageVersion>` entries from `Directory.Packages.props` files in a .NET CPM repo by scanning every `.csproj`/`.props`/`.targets` for `PackageReference` includes, then verifies via `dotnet restore`. |
| [`inline-review`](plugins/eng/skills/inline-review/SKILL.md)                 | Finds and addresses inline code-review comments left in the code, marked with a `rev:` prefix (`// rev:`, `# rev:`, etc.) — treats each like a GitHub review comment, makes the change or answers the question, then removes the ones it handled. |
| [`plan-repl`](plugins/eng/skills/plan-repl/SKILL.md)                         | Research → plan → annotate → implement workflow for non-trivial tasks. Writes research and a plan to `tasks/{name}/`, iterates on the plan via inline `> NOTE:` blockquotes until approved, then implements. |
| [`plan-repl-resume`](plugins/eng/skills/plan-repl-resume/SKILL.md)           | Resumes an in-progress `plan-repl` task by reading its persisted files and cross-referencing with branch state to infer the current phase, then hands off to the right `plan-repl` phase to continue.        |
| [`pr-review-resolver`](plugins/eng/skills/pr-review-resolver/SKILL.md)       | Fetches unresolved GitHub PR review threads, submitted review bodies, and general comments, fixes each in code, commits, replies with the commit hash, and resolves the threads. `--auto` applies its proposed triage without stopping for confirmation.                             |
| [`reorganize-branch-commits`](plugins/eng/skills/reorganize-branch-commits/SKILL.md) | Rewrites a non-default branch's history into clean, logical commits — proposes groupings from the actual diffs, gets approval, backs up, then rebuilds via `git reset` + re-commit (or `git rebase -i`) and checks nothing was lost.  |
| [`righting-software-system-design`](plugins/eng/skills/righting-software-system-design/SKILL.md) | Heavyweight, opt-in, interview-driven system design session faithful to Juval Löwy's *Righting Software*. Walks framing → use cases → interrogative volatility analysis → iDesign component mapping (Manager/Engine/ResourceAccess/Utility) → call-chain validation, surfacing unknown-unknowns along the way and producing a written recommendation report. |
| [`sync-core-docs`](plugins/eng/skills/sync-core-docs/SKILL.md)             | User-invoked router over `sync-core-repo-docs`: accepts `--readme`, `--claude`, `--review` (they combine; no flags runs all three) and hands off to that skill. Invoked by name (`/eng:sync-core-docs` in Claude Code), never auto-triggered.                                              |
| [`sync-core-repo-docs`](plugins/eng/skills/sync-core-repo-docs/SKILL.md)     | Creates or audits a repo's three core doc files — README.md, AGENTS.md (or CLAUDE.md), REVIEW.md — in that dependency order. Missing files are generated from the codebase; existing files are audited for accuracy and fixed after confirmation. README is checked for effective newcomer orientation, AGENTS.md defers to `/init`/`claude-md-improver` where available, and REVIEW.md holds reviewer guidance kept distinct from AGENTS.md. |

Each skill's `description` field enumerates the natural-language phrases that
trigger it — you don't invoke them by name, the agent picks them up from how
you phrase the request.

## `comms` — communications

| Skill                                                       | What it does                                                                                                                                                                                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`de-slop`](plugins/comms/skills/de-slop/SKILL.md)  | Deep-strips AI tells (claudisms) from a draft while preserving its meaning and the writer's voice — the inverse of `dehumanizer`. Sweeps the draft against a bundled snapshot of the living [claudisms banlist](https://claudisms.ai/claudisms.md), catches the constructions a text search misses, then re-sweeps its own rewrites. For writing that ships under your name. |
| [`dehumanizer`](plugins/comms/skills/dehumanizer/SKILL.md)  | Makes a message look AI-generated — the inverse of [the `humanizer`](https://github.com/blader/humanizer), a separate external skill. Injects LLM "tells" (em dashes, rule of three, copula avoidance, AI vocabulary, emoji bold headers) while preserving both the original meaning and its mood, on an intensity dial (`subtle` default, `heavy`, `unhinged`). Mostly for trolling. |

## `behavior` — agent behavior

### Skills

| Skill                                                                          | What it does                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`bro`](plugins/behavior/skills/bro/SKILL.md)                                  | Restates the agent's last message in plain, jargon-free language. Explicit-only (`disable-model-invocation: true`) — invoked by name, not auto-triggered.                                                      |

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
[`writing-for-people.md`](plugins/esond/skills/conversational-voice/references/writing-for-people.md)
before they draft. `conversational-voice` owns the file and `work-item-voice`
reads it by relative path. It holds the rules that are not specific to either
one — the writer pays the compression cost, and how to hand the draft back.
Any voice skill added later reads the same file rather than restating the
rules.
