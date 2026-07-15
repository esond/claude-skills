---
name: plan-repl-auto
description: >-
  Automated multi-model variant of `plan-repl`: a coordinator fans token-heavy research out to
  parallel Sonnet subagents (via the Workflow tool), synthesizes an implementation plan on the
  session model, then a Fable arbiter grills the plan over up to three bounded rounds until it has
  no substantive objections — replacing plan-repl's human `> NOTE:` loop with a cheap→mid→expensive
  model cascade. Explicit-only: invoke via the `/esond:plan-repl-auto` command or by name. Do NOT
  auto-suggest or fire it on general planning/refactor requests — `plan-repl` is the default; use
  this ONLY when the user explicitly asks for `plan-repl-auto` or the automated multi-model plan
  cascade. Flags: `--implement` (run end-to-end and autonomously with no human checkpoints, then fan
  Sonnet subagents to build the plan) and `--arbiter <model>` (arbiter, default Fable).
---

# plan-repl-auto: a cheap → mid → expensive model cascade for planning

You are the **coordinator**, running in the main loop. You do the planning and synthesis yourself
and own the human-in-the-loop checkpoints — that medium-tier judgment stays between you and the
user. You delegate only the parts that don't need you in the room: the token-heavy **research** and
implementation fan-out (through the `Workflow` tool) and the **arbitration**, each pinned to a
specific model, so the raw reading never lands in your context.

Synthesis runs on your session model, and a skill can't remodel its own turn — so set `/model opus`
(the planning sweet spot) before invoking.

**Task and flags:** $ARGUMENTS

## Tiers

| Tier | Runs via | Model | Job |
|------|----------|-------|-----|
| Coordinator + synthesis + triage | main loop (this turn) | session model (Opus recommended) | Decompose, plan, `plan.md`, the checkpoints, drive the arbiter loop |
| Research | `Workflow` fan-out | `sonnet` | Read code/docs/web, return distilled findings |
| Arbiter | subagent, one per round (≤3) | `fable` (`--arbiter`) | Grill the plan — prioritized critique + verdict |
| Implementation | `Workflow` fan-out | `sonnet` | Build the approved plan (only with `--implement`) |

Parse the flags out of the task string first: `--implement` (default off) and `--arbiter <model>`
(default `fable`). Everything left over is the task.

The two fan-out tiers (research, implementation) run through the `Workflow` tool — invoking this
skill is your explicit opt-in to use it. **Pin every fan-out `agent()` call to `model: 'sonnet'`**:
with no `model`, a Workflow agent inherits your session model — whatever `/model` you're on, not
Sonnet. The conversational tiers (synthesis, triage, arbitration) stay in the main loop so a human
can be in the middle; the arbiter is a single subagent per round, not a Workflow, because its loop is
interactive.

Every research/arbiter/implementation agent has an **isolated context** — it sees nothing of this
conversation or its siblings, so every brief must stand alone and carry every path, fact, and
constraint it needs. Ask each for **distilled findings — conclusions plus the few supporting
`file:line` facts, never pasted files** — so the raw material stays in the subagent and only the
distillate crosses back to you.

## Modes

`--implement` is the "I'm not in the loop" switch. It changes the whole run, not just the last step:

- **Default (no `--implement`)** — every phase gate is a human touchpoint. You pause for the user at
  open-question triage and on every arbitration round, and you stop at an approved plan.
- **`--implement`** — fully autonomous. You make the judgment calls yourself, run the bounded
  grilling loop without pausing, and flow straight into building. No human checkpoints.

Where a phase below says "ask the user" or "relay to the user," that applies in **default mode
only**; in `--implement` mode you decide yourself and record the assumption.

## Persistent files

Pick a short kebab-case task name (let the user override) and keep everything in `tasks/{task-name}/`:

| File | Written by | Purpose |
|------|-----------|---------|
| `research.md` | coordinator, from research findings | Consolidated recon |
| `plan.md` | coordinator (you) | The implementation plan |
| `review.md` | coordinator, from arbiter output | The arbiter's critique, per round |

These files are the durable record — the arbiter subagent reads them rather than seeing your
conversation, and they survive context compaction. Keep findings in the files, not only in chat.

---

## Phase 1: Research (Sonnet, `Workflow` fan-out)

Decompose the task into **independent** research questions — areas of the codebase to map, patterns
to find, external docs to check. Batch trivial questions together rather than spawning an agent per
tiny lookup.

Launch a `Workflow` that fans one Sonnet agent per question as a parallel batch — a barrier is
correct here, you need every finding before synthesis. Pin each to `model: 'sonnet'` (see Tiers), and
give each a `schema` so it returns structured distilled findings rather than prose. Each brief:
- **Goal** — the one question, stated so an agent with no other context could answer it.
- **Context** — the paths, task summary, and constraints it needs (it has none of yours).
- **Deliverable** — distilled findings: what's true, the `file:line` evidence, and any pitfalls. Not
  pasted source.

Collect the returned findings and write the consolidated `tasks/{task-name}/research.md`, organized
by area, with an **Open questions** stub for anything the research itself surfaced as unresolved.

In default mode, tell the user research is in `research.md` and that you're moving to synthesis —
they can course-correct now or wait for the open-questions checkpoint in Phase 3. Don't block; the
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

This is the cheap touchpoint that keeps the expensive arbiter rounds focused. Triage each open
question by its tag:
- **`[user]`** — default mode: ask the user directly, right here. `--implement` mode: make the call
  yourself using the research and record the assumption in `plan.md`.
- **`[research]`** — spawn a follow-up Sonnet research agent (`Workflow`, same as Phase 1), then
  append its findings to `research.md`.
- **`[judgment]`** — leave it. That is exactly what the arbiter is for.

Once `[user]` and `[research]` items are resolved, fold the answers and any new research into
`plan.md` yourself and clear the resolved questions. Only `[judgment]` items should remain when the
plan reaches the arbiter.

---

## Phase 4: Arbitrate — bounded adversarial loop (Fable, ≤3 rounds)

The arbiter's job is to **grill** the plan, not rubber-stamp it. Run up to **three** rounds; each
round spawns a **fresh** arbiter subagent so it comes at the revised plan with unanchored eyes. Each
round:

1. **Grill.** Spawn one arbiter subagent (`subagent_type: general-purpose`, `model:
   {--arbiter, default fable}`) briefed to read `research.md` and `plan.md` and attack the plan:
   unsound reasoning, hidden assumptions, missed edge cases, risks, simpler or stronger
   alternatives, and a verdict on each remaining `[judgment]` call. Require it to (a) rank issues by
   severity, (b) separate **substantive** issues — ones that change the plan's correctness,
   approach, or risk — from cosmetic nits, and (c) end with an explicit verdict line, exactly
   `SUBSTANTIVE ISSUES REMAIN` or `NO SUBSTANTIVE ISSUES`. Ask for a critique, not a rewrite.
2. **Record.** Append the critique to `review.md` under a `## Round N` heading — never overwrite
   earlier rounds; the file keeps the full grilling history.
3. **Dispose.**
   - **Default mode:** relay the substantive points to the user with your proposed disposition for
     each (accept / reject-with-reason / your call), and let the user make the judgment calls. This
     is the human touchpoint the cascade exists for — advisory, the user decides what to act on.
   - **`--implement` mode:** you make the calls yourself — accept sound points, reject weak ones with
     a one-line reason. No pause.

   Fold accepted points into `plan.md`, and note in `review.md` what you accepted or rejected and why.
4. **Continue or stop.** End the loop when any of: the arbiter returned `NO SUBSTANTIVE ISSUES`;
   (default mode) the user accepts; or three rounds have run. Otherwise start the next round with a
   fresh arbiter on the revised plan.

After the loop, state the outcome — clean pass, accepted early, or hit the 3-round cap with N points
still open — and move on. The cap is a hard stop; never run a fourth round.

---

## Phase 5: Accept

- **Default mode:** stop here. The plan in `plan.md` is the deliverable — don't begin implementation.
- **`--implement` mode:** skip this stop and go straight to Phase 6. Flowing through without a
  checkpoint is the whole point of the flag.

---

## Phase 6: Implement (Sonnet, `Workflow` fan-out — only with `--implement`)

Break `plan.md` into a task breakdown in your built-in task tracker, then fan it out through a
`Workflow` — no sign-off pause, `--implement` is autonomous. Pin each implement `agent()` to
`model: 'sonnet'` (see Tiers).

Follow the same independence rule as research: **parallelize only tasks that touch disjoint files**;
sequence anything that shares files or depends on another task's output (do the dependency first,
then brief the dependent task with its result). Because the tasks are disjoint, the Sonnet agents
share one working tree safely — no worktree isolation needed. Brief each agent to **edit only** — no
staging, commits, or builds. Each brief is a self-contained ticket: the task, the relevant `plan.md`
excerpt, and what "done" looks like. The agents write their edits straight to the shared tree; you
run the project's build/tests serially as work lands.

Mark tasks done as they land, run the build/test commands as work lands, and if an agent reports the
plan doesn't hold, stop and revise the plan rather than improvising.
