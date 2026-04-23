---
name: permission-consolidator
description: >
  Review and consolidate Claude Code permission entries in settings.json files.
  Use this skill when the user wants to clean up, consolidate, review, or audit
  their Claude Code permissions, or mentions that their allow list is getting long
  or messy. Also trigger when the user mentions "permissions", "settings.local.json",
  or "allow list" in the context of Claude Code configuration.
---

# Permission Consolidator

You help users clean up their Claude Code permission allow lists by finding entries
that can be consolidated and flagging one-off entries that may be stale.

## How permissions work

Claude Code settings files (typically `settings.local.json` in a project's `.claude/`
directory, or `~/.claude/settings.json` globally) contain permission allow lists:

```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "WebFetch(domain:github.com)",
      "mcp__github__pull_request_read"
    ]
  }
}
```

Entries follow patterns:
- `Bash(command subcommand args:*)` — shell commands with wildcard suffixes
- `Bash(command subcommand:specific-value)` — shell commands with exact match (no wildcard)
- `WebFetch(domain:example.com)` — web fetch by domain
- `WebSearch` — bare tool names
- `mcp__server__tool_name` — MCP tool permissions

## Your workflow

### Step 1: Identify the target file(s)

If the user provides a path, use it. Otherwise, look for settings files:
- `<project>/.claude/settings.local.json`
- `~/.claude/settings.json`

Read the file and extract `permissions.allow`.

### Step 2: Analyze for consolidation candidates

Group `Bash(...)` entries by their command prefix hierarchy. Build a mental tree:

```
gh
├── gh pr create:*
├── gh pr view:*
├── gh pr review:*
├── gh api:*
└── gh run:*
```

A consolidation candidate exists when 2+ entries share a command prefix and could
be replaced by a single broader entry. Work from the leaves inward:

- `gh pr create:*`, `gh pr view:*`, `gh pr review:*` → `gh pr:*`
- Then `gh pr:*` + `gh api:*` + `gh run:*` → `gh:*`

Present the **most aggressive reasonable consolidation** as the suggestion, but show
the intermediate options too so the user can pick their comfort level.

Also look for redundant entries — e.g., if both `Bash(dotnet:*)` and
`Bash(dotnet test:*)` exist, the specific one is already covered by the broad one.

### Step 3: Flag suspicious entries

Identify entries that look like one-off commands or accidents:

- **No wildcard**: `Bash(yarn format:fix)` instead of `Bash(yarn format:*)` — may be
  intentionally narrow, or may be an oversight
- **Very long/specific**: entries containing UUIDs, hashes, specific IDs, long argument
  lists (e.g., `Bash(for thread_id in PRRT_kwDOPAqDXs53bRcW ...)`)
- **Shell fragments**: entries that look like parts of a multi-line command that got
  split across permission prompts (e.g., `Bash(do gh:*)`, `Bash(done)`)
- **Uncommon commands**: entries for commands that aren't typical development tools
  (e.g., `Bash(read hash:*)`, `Bash(head:*)`) — these were likely approved for a
  one-time task

### Step 4: Present findings interactively

Use AskUserQuestion to walk through findings **one at a time**. For each item, clearly
show what you found and what you propose.

**For consolidation candidates**, show:
- The current entries that would be replaced
- The proposed consolidated entry
- What the consolidation means in practice (what additional commands it would allow)

**For suspicious entries**, show:
- The entry in question
- Why it looks suspicious
- Ask whether to keep it, remove it, or replace it with something broader

### Step 5: Apply changes

After walking through all findings, summarize the confirmed changes and apply them
to the file. Show a before/after diff of the `allow` array.

## Important considerations

- Never remove entries without user confirmation
- Consolidating `Bash(git add:*)` + `Bash(git commit:*)` into `Bash(git:*)`
  means Claude could also run `git reset`, `git rebase`, etc. without asking.
  Always mention what additional access a consolidation grants so the user can
  make an informed decision.
- Non-Bash entries (`WebFetch`, `WebSearch`, `mcp__*`) don't typically need
  consolidation — leave them alone unless the user asks
- Keep the final allow list sorted alphabetically for readability
- Preserve any other keys in the settings file (`deny`, `ask`, `hooks`, etc.)
