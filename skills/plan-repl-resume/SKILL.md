---
name: plan-repl-resume
description: Resume an in-progress `plan-repl` task from its persisted files. Reads `tasks/{task-name}/research.md`, `plan.md`, and `todo.md`, cross-references them against the current branch's git state to figure out where the previous session actually left off, then continues from that phase. Use this skill whenever the user wants to pick a `plan-repl` task back up — even if they phrase it as "resume the X task", "continue where we left off", "I cleared my context, let's keep going", "pick up the webhook-retries task", "what were we doing on X", or just "let's continue X" with a name that matches a directory under `tasks/`. The two main scenarios: (1) the user cleared their context mid-workflow because research and planning bloated the conversation and wants a fresh slate without losing the work on disk, and (2) the user is returning to a task in a new session after exiting earlier. Trigger proactively when the user references a task name that exists under `tasks/` and hasn't been part of the current conversation yet.
---

# plan-repl-resume

Companion to `plan-repl`. Reload an existing task's persisted files, work out where the
previous session left off by inspecting both the files and the branch state, and continue
from the right phase.

The whole reason `plan-repl` writes to disk is so a session can survive a context clear or a
gap of days. This skill is the on-ramp back in. Don't redo work that's already on disk —
the files are the agreement the previous session ended on, and silently overwriting them
loses that record.

## Step 1 — pick the task

If the user named one ("resume webhook-retries"), check that `tasks/{that-name}/` exists.
If it doesn't, stop and tell the user — list whatever's actually under `tasks/` so they can
correct a typo, and mention that if they meant to start fresh, `plan-repl` is the skill for
that.

Otherwise list candidates:

```bash
ls -1 tasks/ 2>/dev/null
```

If no `tasks/` directory or it's empty, stop. Tell the user there's nothing to resume and
point them at `plan-repl` if they wanted to start a new task. If exactly one task exists,
confirm it's the one. If several, show the list and ask which.

## Step 2 — read the persisted files

For the chosen task, read whichever of these exist, in full:

- `tasks/{task-name}/research.md`
- `tasks/{task-name}/plan.md`
- `tasks/{task-name}/todo.md`

Read the whole file, not just the top. The point of resuming is that durable files — not
chat history — are the source of truth. Skimming defeats the purpose.

## Step 3 — gather branch state

Files alone don't tell you whether implementation work has actually landed. Check git:

```bash
git rev-parse --abbrev-ref HEAD
git status --porcelain
git log --oneline @{upstream}..HEAD 2>/dev/null || git log --oneline -20
git diff --stat $(git merge-base HEAD origin/HEAD 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo HEAD)..HEAD
```

You want a picture of: which branch the user is on, whether the working tree is dirty,
which commits are ahead of the base, and which files have changed. A `todo.md` claiming
five items done means little if the diff is empty — that's a signal the previous session
ended before any code landed, or the user is on a different branch than they were before.

## Step 4 — infer the current phase

Combine file presence, file content, and branch state. Don't read this table as a strict
lookup — it's a starting point. Trust the evidence you actually have.

| Evidence | Likely phase |
|---|---|
| No files in the task dir | Task hasn't really started — fall through to `plan-repl` Phase 1 |
| `research.md` only | Phase 1 done, ready for Phase 2 (planning) |
| `research.md` + `plan.md` with unaddressed `> NOTE:` / `> note:` markers | Phase 3 (annotation cycle), notes pending |
| `research.md` + `plan.md`, no notes, no `todo.md` | Phase 3 done, ready for Phase 4 (task breakdown) |
| `todo.md` exists, all unchecked, branch has no related commits | Phase 4 done, Phase 5 hasn't started |
| `todo.md` has some `[x]`, branch has matching commits / diff | Phase 5 in progress |
| `todo.md` all `[x]`, branch reflects the work | Task likely complete — ask the user what's next rather than assuming |

Two things to actively check rather than assume:

- **Pending notes in `plan.md`.** Scan for lines starting with `> NOTE:` or `> note:`
  (multiline notes continue on subsequent `>` lines). Pending notes mean the annotation
  cycle isn't finished, regardless of whether `todo.md` exists. A `todo.md` plus pending
  plan notes usually means the user added more feedback after the breakdown was generated;
  address the notes before continuing, and ask whether the breakdown needs regenerating.

- **Checkbox/branch consistency for Phase 5.** Cross-reference checked items in `todo.md`
  against the actual diff. If `todo.md` says "migrations applied" is done but no migration
  files appear in `git diff`, surface the mismatch — don't paper over it. Either the
  checkbox is wrong, the user is on the wrong branch, or work happened in another worktree.
  Ask before guessing.

## Step 5 — summarize and propose

Give the user a short status. Make it specific, not a file inventory:

```
Resumed: {task-name}
Branch: {current-branch} ({N commits ahead of base, dirty/clean})
Research: {one-line gist — e.g., "covers the retry-queue module, webhook signing, and existing exponential-backoff patterns"}
Plan: {one-line gist + note count — e.g., "3-phase rollout, 2 unaddressed notes on the migration step"}
Todo: {progress + next item — e.g., "4/9 done, next is 'add idempotency-key column to webhook_events'"}

Looks like we're at Phase {X}: {phase name}. Next action: {what you'd do}. Continue?
```

Wait for the user to confirm before doing anything substantive. The summary's job is to
prove you loaded the right state — not to start work.

## Step 6 — hand off to `plan-repl`

Once the user confirms, continue with the appropriate `plan-repl` phase exactly as
documented there. Don't rerun earlier phases unless the user asks for it. The reading you
did in Steps 2–3 has already grounded you.

If during the handoff the user wants to revise an earlier phase ("the research missed X"),
re-enter that phase normally — `plan-repl`'s files are append/edit-friendly.

## Things not to do

- **Don't** rewrite `research.md` or `plan.md` to "freshen" them on resume. They're the
  durable record of an agreement; rewriting them silently breaks the user's trust in the
  file as a shared artifact.
- **Don't** start implementing without confirming the phase with the user. File state can
  mislead — a half-checked `todo.md` could mean "in progress" or "abandoned and being
  reconsidered". Ask.
- **Don't** invent missing context from chat history that isn't there. After a context
  clear there is no chat history to draw on, and that's fine — the files are the point.
- **Don't** skim the files. The temptation on resume is to read just the headings; do
  that and you'll redo work or miss decisions the previous session captured.
- **Don't** silently fix a checkbox/diff mismatch. Surface it and let the user decide
  what's true.
