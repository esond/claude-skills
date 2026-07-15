---
description: Run the multi-model plan cascade — Sonnet research, Opus synthesis, Fable arbitration.
argument-hint: "<task> [--implement] [--arbiter <model>]"
---

Invoke the **plan-repl-auto** skill for the following task, passing everything through verbatim: $ARGUMENTS

The task text is the planning goal. Flags: `--implement` runs the whole cascade autonomously with
no human checkpoints and fans out parallel Sonnet subagents to build the plan (default off — the
skill otherwise pauses at each gate and stops at an approved plan); `--arbiter <model>` overrides the
arbiter (default Fable). Synthesis runs on the session model, so set `/model opus` before invoking.
The skill owns the runbook — the Workflow research/implement fan-out, the persistent files under
`tasks/{task-name}/`, the open-question triage, and the bounded (≤3-round) adversarial arbitration
loop; this command only routes the invocation and its flags.
