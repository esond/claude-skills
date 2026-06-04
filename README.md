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
| [`clean-unused-cpm-packages`](skills/clean-unused-cpm-packages/SKILL.md)     | Removes unused `<PackageVersion>` entries from `Directory.Packages.props` files in a .NET CPM repo by scanning every `.csproj`/`.props`/`.targets` for `PackageReference` includes, then verifies via `dotnet restore`. |
| [`permission-consolidator`](skills/permission-consolidator/SKILL.md)         | Reviews a Claude Code `settings.json` allow list, proposes consolidations for `Bash(...)` entries that share a command prefix, and flags one-off or stale entries for pruning.                               |
| [`plan-repl`](skills/plan-repl/SKILL.md)                                     | Research → plan → annotate → implement workflow for non-trivial tasks. Writes research and a plan to `tasks/{name}/`, iterates on the plan via inline `> NOTE:` blockquotes until approved, then implements. |
| [`plan-repl-html`](skills/plan-repl-html/SKILL.md)                           | Experimental HTML variant of `plan-repl`. Each phase generates a self-contained interactive HTML page with an in-browser annotation widget that exports notes as JSON for Claude to read on the next turn.   |
| [`plan-repl-resume`](skills/plan-repl-resume/SKILL.md)                       | Resumes an in-progress `plan-repl` task by reading its persisted files and cross-referencing with branch state to infer the current phase, then hands off to the right `plan-repl` phase to continue.        |
| [`pr-review-resolver`](skills/pr-review-resolver/SKILL.md)                   | Fetches unresolved GitHub PR review threads and general comments, fixes each in code, commits, replies with the commit hash, and resolves the threads.                                                       |
| [`reorganize-branch-commits`](skills/reorganize-branch-commits/SKILL.md)     | Rewrites a non-default branch's history into clean, logical commits — proposes groupings from the actual diffs, gets approval, backs up, then rebuilds via `git reset` + re-commit (or scripted `git rebase -i`) with re-signing and hooks run.  |
| [`righting-software-system-design`](skills/righting-software-system-design/SKILL.md) | Heavyweight, opt-in, interview-driven system design session faithful to Juval Löwy's *Righting Software*. Walks framing → use cases → interrogative volatility analysis → iDesign component mapping (Manager/Engine/ResourceAccess/Utility) → call-chain validation, surfacing unknown-unknowns along the way and producing a written recommendation report. |
| [`sign-unsigned-commits`](skills/sign-unsigned-commits/SKILL.md)             | Retroactively signs unsigned commits on the current branch that were authored by the current git user, via a targeted rebase that only amends matching commits.                                              |
| [`sync-repo-docs`](skills/sync-repo-docs/SKILL.md)                           | Creates or audits a repo's three core doc files — README.md, CLAUDE.md, REVIEW.md — in that dependency order. Missing files are generated from the codebase; existing files are audited for accuracy and fixed after confirmation. README is checked for effective newcomer orientation, CLAUDE.md defers to `/init`/`claude-md-improver`, and REVIEW.md holds reviewer guidance kept distinct from CLAUDE.md. |
| [`volatility-decomposition`](skills/volatility-decomposition/SKILL.md)       | **Deprecated** — superseded by [`righting-software-system-design`](skills/righting-software-system-design/SKILL.md), which is a more faithful and complete implementation of the same methodology from Löwy's *Righting Software*. Kept in the marketplace only so users can finish in-progress decompositions started before deprecation. |

Each skill's `description` field enumerates the natural-language phrases that
trigger it — you don't invoke them by name, Claude picks them up from how you
phrase the request.
