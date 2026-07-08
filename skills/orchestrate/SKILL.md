---
name: orchestrate
description: >-
  Orchestrator/workers multi-model workflow that plans big and executes small: the orchestrator
  plans and synthesizes while fanning the token-heavy work out to parallel Sonnet worker
  subagents, each in its own isolated context, then distills their findings into the final
  answer. Use this skill whenever the user wants to orchestrate a big task, "plan big and
  execute small," decompose work and fan out to parallel workers, run a coordinator/worker
  or manager/worker pattern, farm out independent sub-tasks and synthesize the results, or
  split a broad research/refactor/audit across many agents — even if they just say
  "orchestrate this," "fan this out," or "break this up and parallelize it." The task to
  carry out is the argument.
---

# Orchestrate: you plan and synthesize, Sonnet workers execute

You are the **orchestrator**. Your job is the small,
high-leverage part — **planning and synthesis** — while a fleet of **workers** (Sonnet) does
the large, mechanical part in parallel. You decide *what* needs doing and *what it all means*;
the workers do the reading and doing.

**Task:** $ARGUMENTS

Each worker is a subagent with an **isolated context** — it sees nothing of this conversation,
your plan, or its siblings, so every brief must stand alone. The heavy reading stays in worker
contexts and never lands in yours.

## The loop

1. **PLAN** — decide the approach. This is the judgment the setup exists for; spend real thought.
2. **DECOMPOSE** — break the task into *independent* sub-tasks (rules below).
3. **FAN OUT** — dispatch them to parallel `worker` subagents (subagent_type: `worker`;
   `esond:worker` if the bare name collides).
4. **COLLECT** — read each worker's distilled report, not raw material.
5. **SYNTHESIZE** — integrate the reports into one coherent answer.

If you catch yourself opening and grinding through source files or long outputs, stop — that
belongs on a worker. Spend this turn on judgment.

## Decomposition rules

- **Independence.** Sub-tasks must not depend on each other. If worker B needs worker A's output,
  that's a *pipeline* — run it as sequential stages (A, then B briefed with A's result), not one
  parallel batch. Dependencies collapse the parallelism the fan-out exists for.
- **Right-size, and let the count follow.** Don't pick a worker count up front — spawn one per
  independent, right-sized unit of the task. Each worker carries fixed setup overhead, so batch
  trivial units rather than spawning one per tiny item, and split a unit only when it's too big
  to finish without becoming a mini-orchestrator. Past the harness's concurrency limit extra
  workers just queue, so a few meaty briefs beat many thin ones.
- **Self-contained briefs.** A worker can't see your plan, so every detail it needs lives in the
  brief; if two workers need the same context, put it in both.
- **Scope each worker to its sub-task** — state what it owns and what "done" is. The bundled
  `worker` has a general toolset; narrow the *job* in the brief. (For a hard tool boundary, e.g. a
  read-only researcher, dispatch a specialist scoped that way.)
- **Distilled findings, not raw dumps.** Briefs ask for conclusions and the few supporting facts,
  not pasted files — the gigabytes a worker reads must never cross into your context.

## Worker brief shape

Like a standalone task ticket:

- **Goal** — the one sub-task, stated so someone with no other context could do it.
- **Context** — the paths, facts, and constraints it needs (it has none of yours).
- **Deliverable** — what to return and in what shape. Ask for a distilled summary; name the format
  if you'll merge many workers' outputs (e.g. "a three-line summary plus the file:line of each match").

## Fan-out mechanics

Spawn workers with **multiple Agent-tool calls in one message** — that's what runs them
concurrently. Wait for all to report before synthesizing. If one returns an infrastructure error
(timeout, rate limit), re-dispatch to a fresh worker. If workers edit files in parallel and might
collide, run each in an isolated worktree (`isolation: worktree`).

## Synthesize (and check the premise)

Integrate the reports into one answer — cite what each worker found, reconcile conflicts, fill
gaps with a follow-up worker. Don't just concatenate. One trap: the split can verify every
*delegated* fact yet rest on a wrong *premise* (workers confirm details about the wrong set of
items). If the premise is itself uncertain, spend one delegation verifying it.

## Choosing the planner model and effort

The orchestrator runs on **your session model and effort** — this skill doesn't pin them, so
whatever you've set with `/model` and `/effort` is what plans and synthesizes here. That's the
knob: set them before invoking (**Opus at xhigh** is the sweet spot for planning) and dial
either down for a lighter task or up when you need it. A skill's own turn can't take a model or
effort override inline, so the session settings are how you control it per run. Workers stay on
Sonnet regardless.

## Using a repo's own specialist as a worker

If a repo subagent's domain fits a sub-task (say a `critter-stack-specialist` for a
Marten/Wolverine slice), dispatch **that** agent as the worker. Pass `model: sonnet` so it runs
at the worker tier regardless of its own frontmatter, and keep the brief self-contained as always.
