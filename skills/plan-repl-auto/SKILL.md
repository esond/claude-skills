---
name: plan-repl-auto
description: >-
  Automated multi-model variant of `plan-repl`: a coordinator fans token-heavy research out to
  parallel Sonnet subagents, synthesizes the findings into an implementation plan on the session
  model, then a Fable subagent arbitrates it — replacing plan-repl's human `> NOTE:` loop with a
  cheap→mid→expensive model cascade. Explicit-only: invoke via the `/esond:plan-repl-auto` command or by
  name. Do NOT auto-suggest or fire it on general planning/refactor requests — `plan-repl` is the
  default; use this ONLY when the user explicitly asks for `plan-repl-auto` or the automated
  multi-model plan cascade. Flags: `--implement` (fan out Sonnet subagents to build the approved
  plan) and `--arbiter <model>` (arbiter, default Fable).
---

# plan-repl-auto: a cheap → mid → expensive model cascade for planning

You are the **coordinator**, running in the main loop. You do the planning and synthesis yourself
and own the human-in-the-loop checkpoints — that medium-tier judgment stays between you and the
user. You delegate only the parts that don't need you in the room: the token-heavy **research** and
the **arbitration**, each to a subagent pinned to a specific model, so the raw reading never lands
in your context.

Synthesis runs on your session model, and a skill can't remodel its own turn — so set `/model opus`
(the planning sweet spot) before invoking.

**Task and flags:** $ARGUMENTS

## Tiers

| Tier | Runs in | Model | Job |
|------|---------|-------|-----|
| Coordinator + synthesis | main loop (this turn) | session model (Opus) | Decompose, plan, `plan.md`, the checkpoints |
| Research | subagent(s), parallel | `sonnet` | Read code/docs/web, return distilled findings |
| Arbiter | subagent | `fable` (`--arbiter`) | Critique the plan — advisory |
| Implementation | subagent(s), parallel | `sonnet` | Build the approved plan (only with `--implement`) |

Parse the flags out of the task string first: `--implement` (default off) and `--arbiter <model>`
(default `fable`). Everything left over is the task.

Each subagent has an **isolated context** — it sees nothing of this conversation or its siblings, so
every brief must stand alone and carry every path, fact, and constraint it needs. Ask each for
**distilled findings — conclusions plus the few supporting `file:line` facts, never pasted files** —
so the raw material stays in the subagent and only the distillate crosses back to you.

Spawn all subagents with `subagent_type: general-purpose` and the tier's `model:` on the Agent call.
Launch a parallel batch as **multiple Agent calls in one message**.

## Persistent files

Pick a short kebab-case task name (let the user override) and keep everything in `tasks/{task-name}/`:

| File | Written by | Purpose |
|------|-----------|---------|
| `research.md` | coordinator, from research findings | Consolidated recon |
| `plan.md` | coordinator (you) | The implementation plan |
| `review.md` | coordinator, from arbiter output | Fable's critique, per round |

These files are the durable record — the arbiter subagent reads them rather than seeing your
conversation, and they survive context compaction. Keep findings in the files, not only in chat.

---

## Phase 1: Research (Sonnet, parallel)

Decompose the task into **independent** research questions — areas of the codebase to map, patterns
to find, external docs to check. One subagent per question; batch trivial questions together rather
than spawning a subagent per tiny lookup. Spawn them all in one message with `model: sonnet`.

Each brief:
- **Goal** — the one question, stated so an agent with no other context could answer it.
- **Context** — the paths, task summary, and constraints it needs (it has none of yours).
- **Deliverable** — distilled findings: what's true, the `file:line` evidence, and any pitfalls. Not
  pasted source.

Collect the returned findings and write the consolidated `tasks/{task-name}/research.md`, organized
by area, with an **Open questions** stub for anything the research itself surfaced as unresolved.

Tell the user research is in `research.md` and that you're moving on to synthesis — they can
course-correct now or wait for the open-questions checkpoint in Phase 3. Don't block on a reply; the
research phase isn't a hard gate.

---

## Phase 2: Synthesis (you, main loop)

Read `tasks/{task-name}/research.md` and write `tasks/{task-name}/plan.md` yourself. This is the
medium-tier judgment the cascade exists to keep in your hands — spend real thought here. Include:
- High-level approach and rationale
- Specific files to create or modify, with paths and key code snippets
- Trade-offs considered and decisions made
- An **`## Open Questions`** section, each question tagged with how to resolve it:
  `[user]` (a product/preference call), `[research]` (needs more facts), or `[judgment]` (a genuine
  architectural judgment call)

The plan should be detailed enough that implementation is mechanical.

---

## Phase 3: Resolve open questions (coordinator + user)

This is the cheap human touchpoint that keeps the expensive arbiter turn focused. Triage each open
question by its tag:
- **`[user]`** — ask the user directly, right here. Seconds to answer.
- **`[research]`** — spawn a follow-up Sonnet research subagent, then append its findings to
  `research.md`.
- **`[judgment]`** — leave it. That is exactly what the arbiter is for.

Once `[user]` and `[research]` items are resolved, fold the answers and any new research into
`plan.md` yourself and clear the resolved questions. Only `[judgment]` items should remain when the
plan reaches the arbiter.

---

## Phase 4: Arbitrate (Fable, subagent — advisory loop)

Spawn an arbiter subagent with `model: {--arbiter, default fable}`, briefed to read `research.md`
and `plan.md` and critique the plan: soundness, risks, missed edge cases, simpler or stronger
alternatives, and a verdict on the remaining `[judgment]` calls. Ask for a prioritized critique, not
a rewrite.

Append the critique to `tasks/{task-name}/review.md` under a heading for this round (don't
overwrite earlier rounds — the file keeps the full arbitration history) and relay the key points to
the user. The
critique is **advisory — the user decides what to act on and when the plan is good enough**. For
points worth addressing, revise `plan.md` yourself, then optionally send the revised plan back to a
fresh arbiter subagent for another round. Loop until the user accepts.

---

## Phase 5: Accept

When the user accepts the plan, stop here — unless `--implement` was passed. The plan in `plan.md`
is the deliverable. Don't begin implementation without both `--implement` and an explicit go-ahead.

---

## Phase 6: Implement (Sonnet, parallel — only with `--implement`)

Break `plan.md` into a task breakdown in your built-in task tracker and get the user's sign-off
before building.

Dispatch to Sonnet subagents (`model: sonnet`), following the same independence rule as research:
**parallelize only tasks that touch disjoint files**; sequence anything that shares files or depends
on another task's output (do the dependency first, then brief the dependent task with its result).
That disjoint-files rule is what lets parallel subagents share one working tree without colliding.
Each brief is a self-contained ticket — the task, the relevant `plan.md` excerpt, and what "done"
looks like; subagents edit and report back, you integrate.

Mark tasks done as they land, run the project's test/build commands as you integrate, and if a
subagent reports the plan doesn't hold, stop and revise the plan rather than improvising.
