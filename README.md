# claude-skills

Eric's personal [Claude Code](https://claude.ai/code) plugin marketplace,
published as a single plugin (`esond`) containing skills.

## Installation

Run these inside Claude Code:

```text
/plugin marketplace add esond/claude-skills
/plugin install esond@claude-skills
```

That's two steps: the first registers this repo as a marketplace; the second
installs the `esond` plugin from it.

## Updating

```text
/plugin marketplace update claude-skills
```

## Managing

```text
/plugin disable esond@claude-skills
/plugin enable esond@claude-skills
/plugin uninstall esond@claude-skills
```

## Skills included

| Skill                                                                        | What it does                                                                                                                                                                                                 |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`advise`](skills/advise/SKILL.md)                                           | Advisor/executor multi-model workflow. Does the work on Sonnet 5 and consults a bundled Opus 4.8 [`advisor`](agents/advisor.md) subagent for strategy at decision points — before non-trivial work, at design forks, and when stuck. The advisor model is overridable per-invocation, and a repo's own specialist can stand in as the advisor (pinned to Opus). |
| [`clean-unused-cpm-packages`](skills/clean-unused-cpm-packages/SKILL.md)     | Removes unused `<PackageVersion>` entries from `Directory.Packages.props` files in a .NET CPM repo by scanning every `.csproj`/`.props`/`.targets` for `PackageReference` includes, then verifies via `dotnet restore`. |
| [`dehumanizer`](skills/dehumanizer/SKILL.md)                                 | Makes a message look AI-generated — the inverse of [the `humanizer`](https://github.com/blader/humanizer), a separate external skill. Injects LLM "tells" (em dashes, rule of three, copula avoidance, AI vocabulary, emoji bold headers) while preserving both the original meaning and its mood, on an intensity dial (`subtle` default, `heavy`, `unhinged`). Mostly for trolling. |
| [`orchestrate`](skills/orchestrate/SKILL.md)                                 | Orchestrator/workers workflow on the "plan big, execute small" pattern. Plans and synthesizes on Opus 4.8, fans the token-heavy work out to parallel Sonnet 5 [`worker`](agents/worker.md) subagents in isolated contexts, then distills their findings. Planner model is set in frontmatter (swap to Fable 5 while available); workers stay on Sonnet, and a repo's own specialist can stand in as a worker. |
| [`permission-consolidator`](skills/permission-consolidator/SKILL.md)         | Reviews a Claude Code `settings.json` allow list, proposes consolidations for `Bash(...)` entries that share a command prefix, and flags one-off or stale entries for pruning.                               |
| [`plan-repl`](skills/plan-repl/SKILL.md)                                     | Research → plan → annotate → implement workflow for non-trivial tasks. Writes research and a plan to `tasks/{name}/`, iterates on the plan via inline `> NOTE:` blockquotes until approved, then implements. |
| [`plan-repl-html`](skills/plan-repl-html/SKILL.md)                           | Experimental HTML variant of `plan-repl`. Each phase generates a self-contained interactive HTML page with an in-browser annotation widget that exports notes as JSON for Claude to read on the next turn.   |
| [`plan-repl-resume`](skills/plan-repl-resume/SKILL.md)                       | Resumes an in-progress `plan-repl` task by reading its persisted files and cross-referencing with branch state to infer the current phase, then hands off to the right `plan-repl` phase to continue.        |
| [`pr-review-resolver`](skills/pr-review-resolver/SKILL.md)                   | Fetches unresolved GitHub PR review threads and general comments, fixes each in code, commits, replies with the commit hash, and resolves the threads.                                                       |
| [`reorganize-branch-commits`](skills/reorganize-branch-commits/SKILL.md)     | Rewrites a non-default branch's history into clean, logical commits — proposes groupings from the actual diffs, gets approval, backs up, then rebuilds via `git reset` + re-commit (or scripted `git rebase -i`) with re-signing and hooks run.  |
| [`righting-software-system-design`](skills/righting-software-system-design/SKILL.md) | Heavyweight, opt-in, interview-driven system design session faithful to Juval Löwy's *Righting Software*. Walks framing → use cases → interrogative volatility analysis → iDesign component mapping (Manager/Engine/ResourceAccess/Utility) → call-chain validation, surfacing unknown-unknowns along the way and producing a written recommendation report. |
| [`sign-unsigned-commits`](skills/sign-unsigned-commits/SKILL.md)             | Retroactively signs unsigned commits on the current branch that were authored by the current git user, via a targeted rebase that only amends matching commits.                                              |
| [`sync-core-repo-docs`](skills/sync-core-repo-docs/SKILL.md)                 | Creates or audits a repo's three core doc files — README.md, CLAUDE.md, REVIEW.md — in that dependency order. Missing files are generated from the codebase; existing files are audited for accuracy and fixed after confirmation. README is checked for effective newcomer orientation, CLAUDE.md defers to `/init`/`claude-md-improver`, and REVIEW.md holds reviewer guidance kept distinct from CLAUDE.md. |
| [`volatility-decomposition`](skills/volatility-decomposition/SKILL.md)       | **Deprecated** — superseded by [`righting-software-system-design`](skills/righting-software-system-design/SKILL.md), which is a more faithful and complete implementation of the same methodology from Löwy's *Righting Software*. Kept in the marketplace only so users can finish in-progress decompositions started before deprecation. |

Each skill's `description` field enumerates the natural-language phrases that
trigger it — you don't invoke them by name, Claude picks them up from how you
phrase the request.

## Agents included

Two skills bundle their own subagents, which live in [`agents/`](agents/) and run on a
pinned model regardless of the session model. The skills spawn them at the right moments;
you don't invoke them directly.

| Agent                          | Model    | Used by                                          | What it does                                                                                                                                    |
| ------------------------------ | -------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [`advisor`](agents/advisor.md) | Opus 4.8 | [`advise`](skills/advise/SKILL.md)               | Read-only staff-level advisor. Returns a recommendation, short plan, risks, and course-correction at a decision point without implementing.      |
| [`worker`](agents/worker.md)   | Sonnet 5 | [`orchestrate`](skills/orchestrate/SKILL.md)     | Executes one self-contained sub-task in an isolated context and returns distilled findings, not raw dumps.                                       |

## Commands included

Commands are invoked by name as `/esond:<command>`, with explicit flag
arguments — a deterministic counterpart to skills' natural-language triggering.

| Command                                                  | What it does                                                                                                                                                                          |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`/esond:sync-core-docs`](commands/sync-core-docs.md)    | Thin wrapper over the [`sync-core-repo-docs`](skills/sync-core-repo-docs/SKILL.md) skill. Accepts `--readme`, `--claude`, `--review` (they combine; no flags runs all three) and hands off to the skill. |
