---
name: plan-repl
description: Structured research-plan-implement workflow for non-trivial tasks. Researches the codebase deeply and writes findings to a persistent file, then produces an annotatable implementation plan the user can mark up with inline notes, iterates through annotation cycles until approved, builds a task breakdown, and finally implements. Use this skill whenever the user has a multi-step implementation task, feature request, refactoring, or architectural change. Suggest this workflow when you detect tasks that would benefit from upfront research and planning — multi-file changes, unfamiliar code, architectural decisions, or anything where jumping straight to code would be risky. Even if the user doesn't explicitly ask for "research" or "planning", suggest it for substantial work.
---

# Research → Plan → Implement

A structured workflow that front-loads understanding before writing code. The core idea: never
let Claude write code until a written plan has been reviewed and approved by the user.

## When to suggest this workflow

When you detect a task that involves:
- Multiple files or components
- Unfamiliar parts of the codebase
- Architectural decisions or trade-offs
- Anything where jumping straight to code would be risky

Suggest it naturally: "This looks like it'd benefit from some upfront research. Want me to
start with a deep dive into the relevant code?"

If the user declines, respect that and proceed normally.

## Starting a task

Before anything else, suggest a short kebab-case name for the task based on the user's prompt.
For example, if the user says "add webhook retry logic", suggest `webhook-retries`. Let the
user override it.

All persistent documents for this task then live in `tasks/{task-name}/`:

| File | Purpose |
|------|---------|
| `tasks/{task-name}/research.md` | Research findings from codebase exploration |
| `tasks/{task-name}/plan.md` | Implementation plan with code snippets and trade-offs |
| `tasks/{task-name}/todo.md` | Granular task breakdown with checkboxes |

These files are the shared workspace between you and the user. Write everything important to
these files — never leave findings only in chat.

---

## Phase 1: Research

**Goal**: Build genuine understanding of the relevant code before planning.

Ask the user: "What areas of the codebase should I research for this?"

Then explore deeply. Research means reading the actual code, not skimming file names. Go
through:
- The specific files and modules that will be touched
- Adjacent code that interacts with those modules
- Existing patterns, conventions, and abstractions already in use
- Edge cases, caching layers, validation logic, error handling
- Tests that cover the relevant areas

Use emphatic, specific language when exploring. Go through everything in detail. Don't settle
for surface-level understanding — the whole point of this phase is to prevent implementations
that work in isolation but break the surrounding system.

Write findings to `tasks/{task-name}/research.md` with clear sections:
- What you found and how things currently work
- Existing patterns the implementation should follow
- Potential pitfalls or complications
- Open questions for the user

**Transition**: Tell the user: "Research is in `tasks/{task-name}/research.md` — take a look and let me
know if anything's off or missing before we move to planning."

Wait for the user before proceeding.

---

## Phase 2: Planning

**Goal**: Produce a detailed, annotatable implementation plan.

Ask the user: "Ready for the plan — anything specific about how you want this implemented?"
Incorporate their answer plus the research findings.

If the user has a reference implementation (similar open-source code, an existing feature in
the codebase to model after), incorporate it to anchor the approach rather than designing from
scratch. You can ask: "Is there existing code I should use as a reference for this?"

Write the plan to `tasks/{task-name}/plan.md` including:
- High-level approach and rationale
- Specific files to create or modify, with paths
- Code snippets showing key changes
- Trade-offs considered and decisions made
- Anything you're uncertain about, flagged clearly

The plan should be detailed enough that implementation becomes mechanical — the creative
decisions happen here, not during coding.

**Transition**: "Plan is in `tasks/{task-name}/plan.md`. Review it in your editor and add any notes —
I'll address them in the next pass."

Wait for the user before proceeding.

---

## Phase 3: Annotation cycle

**Goal**: Iterate on the plan until the user is satisfied. This is where maximum value gets
added — the user's domain knowledge and preferences shape the plan into something worth
implementing.

The cycle:
1. User opens `tasks/{task-name}/plan.md` in their editor and adds inline notes
2. User tells you to address the notes
3. You re-read the file, find all notes, address each one, and update the plan
4. Repeat until no notes remain

### Note format

Notes use blockquote markers, case-insensitive:

```markdown
> NOTE: Use drizzle:generate for migrations, not raw SQL

> NOTE: This section should be a PATCH endpoint, not PUT.
> The current API convention uses PATCH for partial updates
> throughout the codebase.
```

Find all lines starting with `> NOTE:` or `> note:`. Multiline notes continue on subsequent
`>` lines.

When addressing a note:
- Update the relevant section of the plan to incorporate the feedback
- Remove the note marker once addressed
- If a note is ambiguous or you disagree, respond in chat before changing the plan

After addressing all notes, tell the user: "I've addressed all notes and updated the plan.
Take another look — add more notes or tell me it's good to go."

Expect 1-6 annotation passes. Don't rush the user through this phase — it's the highest
leverage part of the entire workflow.

---

## Phase 4: Task breakdown

**Goal**: Create a granular, trackable task list from the approved plan.

Once the user approves the plan, generate a task breakdown in `tasks/{task-name}/todo.md`:

```markdown
# Task Breakdown

## Phase 1: [Description]
- [ ] Task 1 — specific, actionable description
- [ ] Task 2

## Phase 2: [Description]
- [ ] Task 3
- [ ] Task 4
```

Each task should be small enough to be a single, clear change. Show the breakdown to the user
and wait for their sign-off.

**Do not begin implementation.** After presenting the task breakdown, stop and wait for the
user to explicitly tell you to implement. They may want to adjust the tasks, reorder them, or
go back and revise the plan. Only proceed to Phase 5 when the user gives a clear instruction
like "implement it", "go ahead", or "start building".

---

## Phase 5: Implementation

**Goal**: Execute the approved plan. The creative work is done — this is mechanical execution.

Work through `tasks/{task-name}/todo.md` in order:
- Mark each task `[x]` as you complete it
- Run the project's test/typecheck/build commands continuously — don't let issues accumulate
- If something doesn't work as planned, stop and tell the user rather than improvising

### Staying on track

- Don't add features that aren't in the plan
- Don't refactor surrounding code
- Don't add comments or docs beyond what the plan specifies
- If you discover the plan needs to change, stop and discuss before continuing

### Responding to feedback during implementation

Once implementation is underway, the user's feedback will be short and direct. Match their
brevity — don't over-explain during this phase.
