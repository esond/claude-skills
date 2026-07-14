---
description: Run the multi-model plan cascade — Sonnet research, Opus synthesis, Fable arbitration.
argument-hint: "<task> [--implement] [--arbiter <model>]"
---

Invoke the **plan-repl-auto** skill for the following task, passing everything through verbatim: $ARGUMENTS

The task text is the planning goal. Flags: `--implement` fans out parallel Sonnet subagents to
build the plan once approved (default off — the skill otherwise stops at an approved plan);
`--arbiter <model>` overrides the arbiter (default Fable). Synthesis runs on the session model, so
set `/model opus` before invoking. The skill owns the runbook — the tier subagents, the persistent
files under `tasks/{task-name}/`, the open-question triage, and the advisory arbitration loop; this
command only routes the invocation and its flags.
