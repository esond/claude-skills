# claude-skills

Eric's personal [Claude Code](https://claude.ai/code) plugin marketplace,
published as a single plugin (`esond`) containing skills, agents, and commands.

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
| [`permission-consolidator`](skills/permission-consolidator/SKILL.md)         | Reviews a Claude Code `settings.json` allow list, proposes consolidations for `Bash(...)` entries that share a command prefix, and flags one-off or stale entries for pruning.                               |
| [`plan-repl`](skills/plan-repl/SKILL.md)                                     | Research → plan → annotate → implement workflow for non-trivial tasks. Writes research and a plan to `tasks/{name}/`, iterates on the plan via inline `> NOTE:` blockquotes until approved, then implements. |
| [`pr-review-resolver`](skills/pr-review-resolver/SKILL.md)                   | Fetches unresolved GitHub PR review threads and general comments, fixes each in code, commits, replies with the commit hash, and resolves the threads.                                                       |
| [`sign-unsigned-commits`](skills/sign-unsigned-commits/SKILL.md)             | Retroactively signs unsigned commits on the current branch that were authored by the current git user, via a targeted rebase that only amends matching commits.                                              |

Each skill's `description` field enumerates the natural-language phrases that
trigger it — you don't invoke them by name, Claude picks them up from how you
phrase the request.
