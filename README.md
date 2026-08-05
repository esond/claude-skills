# claude-skills

Eric's personal [Claude Code](https://claude.ai/code) plugin marketplace. It
publishes four plugins — `eng`, `comms`, `behavior`, and `docs` — so each
bucket can be toggled on and off independently, per project or context.

| Plugin                        | Bucket                                                                              |
| ----------------------------- | ----------------------------------------------------------------------------------- |
| [`eng`](plugins/eng)          | Writing software: planning, review, git history, .NET hygiene, design, repo docs.   |
| [`comms`](plugins/comms)      | External communications and human-facing writing.                                   |
| [`behavior`](plugins/behavior) | Tweaks to Claude's behavior and Claude Code configuration.                          |
| [`docs`](plugins/docs)        | Documentation: Diátaxis-guided writing and auditing of docs.                        |

## Installation

Run these inside Claude Code:

```text
/plugin marketplace add esond/claude-skills
/plugin install eng@claude-skills
/plugin install comms@claude-skills
/plugin install behavior@claude-skills
/plugin install docs@claude-skills
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
| [`toggle-simplified-english`](plugins/behavior/skills/toggle-simplified-english/SKILL.md) | Enables, disables, or toggles the Simplified Technical English output style by editing the `outputStyle` key in Claude Code settings, instead of hand-editing JSON. Explicit-only (`disable-model-invocation: true`) — run it as `/behavior:toggle-simplified-english`, since it writes to a settings file. Confirms which scope to write (user or project-local) before touching anything. |

### Output styles

An output style appends its instructions to Claude Code's system prompt, so it
shapes every response instead of firing on a trigger phrase. Only one can be
active at a time, and it replaces whichever built-in style you were on.

| Output style                                                                            | What it does                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`Simplified Technical English`](plugins/behavior/output-styles/simplified-technical-english.md) | Shapes every message Claude sends with ASD-STE100 Simplified Technical English: short sentences, active voice, approved verb forms, one meaning per word, no idioms. Scoped to transcript prose only — never code, commits, PR comments, file contents, drafts for other people, or Claude's own thinking. Sets `keep-coding-instructions: true`, so Claude Code's software-engineering system prompt loads exactly as it does under the Default style. |

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
