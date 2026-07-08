---
name: advise
description: >-
  Advisor/executor multi-model workflow: do the actual work on Sonnet 5 while consulting an
  Opus 4.8 advisor subagent for strategy at decision points — before non-trivial work, at
  major design forks, and when stuck. Use this skill whenever the user wants to work with an
  advisor, run the advisor/executor pattern, "execute on Sonnet and plan with Opus," get
  strategic guidance from a stronger model mid-task, or have a smarter model sanity-check the
  approach — even if they just say "advise," "use the advisor workflow," or "run this with an
  advisor." The task to carry out is the argument.
model: claude-sonnet-5
---

# Advise: you execute on Sonnet, an Opus advisor plans

You are the **executor**, pinned to Sonnet 5, so *you* do all the actual work — reading,
editing, running commands, testing. A higher-intelligence **advisor** (Opus 4.8) is available
on demand: Opus-level thinking at the few moments that decide the task, Sonnet-level doing for
everything else. Do the doing yourself — outsourcing grunt work to the advisor defeats the point.

**Task:** $ARGUMENTS

## When to consult

Consult at genuine decision points, **not every step**:

1. **Before non-trivial work** — after you've oriented (found the files, seen what's there) but
   *before* you commit to an approach or start writing. Orientation isn't substantive work;
   writing, editing, and declaring an answer are.
2. **At a major fork** — more than one reasonable approach and the choice is expensive to reverse.
3. **When stuck** — errors recurring, approach not converging, results that don't fit.
4. **Before declaring done** on anything non-trivial — but write your deliverable to disk
   *first*, then consult; a durable result survives even if the consult runs long.

**Skip it for trivial tasks** (a one-line fix, a rename). If the advisor confirms your plan,
proceed — don't re-consult a green light. Its value is highest on the first call, before the
approach crystallizes.

## How to consult: write a self-contained brief

Spawn the `advisor` subagent (subagent_type: `advisor`; `esond:advisor` if the bare name
collides). It can't see this conversation, so the brief must stand alone:

- **The task** — what you're ultimately trying to accomplish.
- **What you've done and observed** — relevant files (point it at specific paths to read), what
  you've tried, any errors.
- **The specific decision** — the one question. "Which of these two approaches," not "any thoughts?"

It reads the code you point it at and returns a recommendation, plan, risks, and
course-correction. It does **not** write code — you do.

## Choosing the advisor model

The advisor defaults to **Opus 4.8** (its frontmatter). Since it's a subagent, the `model:` you
pass in the Agent call overrides that per-invocation — so if the request names a model (e.g.
`fable` while you have access), spawn it with that. Otherwise use Opus 4.8; the executor stays
on Sonnet 5 regardless.

## How to weigh the advice

Give it serious weight, but it's advice, not a command:

- If a step **fails empirically** or **primary-source evidence** contradicts it, adapt. A passing
  self-test isn't evidence the advice was wrong — it may mean your test doesn't check what the
  advice guarded against.
- If your evidence and the advisor point different ways, **don't silently switch** — surface the
  conflict in one follow-up consult ("I found X, you suggested Y, which constraint breaks the tie?").

## Using a repo's own specialist as the advisor

If the repo defines a subagent whose domain squarely fits the task (say a
`critter-stack-specialist` for a Marten/Wolverine question), consult **that** agent as the
advisor instead — you get its domain expertise over a generic staff engineer. Pass `model: opus`
so it runs at advisor intelligence regardless of its own frontmatter (the role sets the tier; the
agent supplies the expertise).

Caveat: per-invocation you override the *model* but not the *tools*, so a broad-tool specialist
could start editing — tell it in the brief to **advise only, not implement**. Only the bundled
`advisor` enforces read-only via frontmatter; when you need that guarantee or no specialist fits,
use it.
