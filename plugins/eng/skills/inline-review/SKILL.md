---
name: inline-review
description: >-
  Find and address inline code-review comments left in the code, marked with
  the `rev:` prefix (e.g. `// rev:`, `# rev:`, `-- rev:`). These are a manual
  code review done inline instead of on GitHub — each comment is a question,
  suggestion, concern, or change request about the nearby code. Use this skill
  whenever the user asks you to address, handle, resolve, go through, or
  respond to their inline review comments, rev comments, or `rev:` comments —
  even when phrased tersely, like "address my rev comments", "handle the
  reviews", "go through the rev: notes", "I left some inline comments",
  "respond to my review", or just "address these" right after leaving such
  comments. Trigger whenever the request references `rev:` comments in the
  code.
---

# inline-review

The user has left inline review comments in the code, each prefixed with `rev:`
after the language's comment delimiter (`// rev:`, `# rev:`, `-- rev:`,
`/* rev: ... */`, etc.). Treat them like a GitHub code review that happened
inline: each one is a question, suggestion, concern, or change request about the
code near it.

## Step 1 — Find every `rev:` comment

Search the codebase (or the files/paths the user pointed at) for the `rev:` marker.
Use a delimiter-agnostic search so no comment style is missed:

```
rg -n "rev:" --glob '!**/node_modules/**'
```

Collect every hit with its file, line, and full comment text. If none are found,
say so and stop — don't invent work.

## Step 2 — Address each comment

Read the surrounding code so you understand what each comment is really asking,
then handle it on its own terms:

- **A question** → answer it. If the answer implies a code change, make it.
- **A suggestion or change request** → make the change.
- **A concern** → investigate; fix it if real, or explain why it's fine.
- **Ambiguous or you disagree** → don't silently comply or silently skip. Say
  what you'd do and why, and ask if it's a real judgment call.

Make the changes surgically — only what each comment asks for, matching the
surrounding style. Don't address adjacent code that has no `rev:` comment.

## Step 3 — Remove the comments you've addressed

Delete each `rev:` comment once its point is handled, so the marker means
"outstanding" and the code isn't left littered with them. Leave a `rev:` comment
in place only if you're explicitly deferring it or waiting on the user's answer
— and call out which ones you left and why.

## Step 4 — Report back

Give a short per-comment rundown: what each one asked and how you handled it
(changed X, answered Y, deferred Z). Keep it tight — one line per comment is
usually enough.

## Things not to do

- Don't run tests, commit, or open a PR unless asked — this skill just addresses
  the comments.
- Don't refactor or "improve" code that no `rev:` comment mentions.
- Don't remove a `rev:` comment you haven't actually addressed.
