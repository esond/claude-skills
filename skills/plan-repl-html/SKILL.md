---
name: plan-repl-html
description: Experimental HTML variant of `plan-repl`. Same research → plan → annotate → implement workflow, but each phase produces an interactive HTML page instead of a markdown file — with an in-browser annotation widget that exports notes back to a JSON file Claude reads on the next turn. Use this skill whenever the user explicitly asks for the HTML version of plan-repl, wants to prototype or evaluate the HTML output format, says things like "let's try the HTML plan thing", "use plan-repl-html", "render the plan as HTML", "I want the experimental HTML workflow", "do the plan thing but in HTML", "annotate this in the browser instead of in markdown", or references Thariq's "HTML is the new markdown" post in the context of planning. Do NOT auto-suggest this for general planning tasks — `plan-repl` is the default; `plan-repl-html` is an opt-in experiment. Trigger only when the user has explicitly asked for the HTML variant.
---

# plan-repl-html (experimental)

A prototype variant of `plan-repl`. Same five phases (research, plan, annotation
cycle, task breakdown, implementation), but each phase produces an HTML page
with an interactive annotation widget. Each task folder also contains a
sibling `.repl-assets/` directory holding the shared stylesheet and widget JS
(one snapshot per task). The goal is to evaluate whether HTML output unlocks
meaningfully better review affordances — timelines, diagrams, severity tags,
collapsible sections, in-page navigation, exportable structured annotations —
compared to the markdown flow.

This skill is explicitly experimental. When something feels awkward, surface
that to the user rather than smoothing it over; the friction is the point.

## What this experiments with

- **Richer artifacts at each phase**: SVG data-flow diagrams in research, a
  timeline + risk table in the plan, a checkbox grid in the todo. Things HTML
  is good at and markdown isn't.
- **In-browser annotation**: the user clicks a section, types a note, and
  exports a per-phase JSON file Claude reads on the next turn. Replaces
  the `> NOTE:` blockquote convention from `plan-repl`.
- **Annotation in every phase**, not just planning. Research findings and the
  todo breakdown become annotatable too — the working hypothesis is that
  catching mistakes in research is even cheaper than catching them in the plan.
- **Shared CSS + JS per task**: the scaffold's styling and annotation widget
  live in two files (`style.css`, `annotations.js`) copied once per task to
  `tasks/{task-name}/.repl-assets/`. Each phase HTML links to them via
  relative paths. This trades the previous single-file shareability for
  much cheaper regeneration on each annotation round, and eliminates CSS
  drift between phase pages of the same task.

## Starting a task

Suggest a short kebab-case name based on the user's prompt. Persisted files
live in `tasks/{task-name}/` alongside any markdown files from a parallel
`plan-repl` run:

| File | Purpose |
|------|---------|
| `tasks/{task-name}/research.html` | Research findings, annotatable per section |
| `tasks/{task-name}/plan.html` | Implementation plan, annotatable per section |
| `tasks/{task-name}/todo.html` | Task breakdown, checkboxes are source of truth |
| `tasks/{task-name}/{phase}.annotations.json` | Latest annotation export from the user, per phase |
| `tasks/{task-name}/.repl-assets/style.css` | Shared stylesheet, copied from the skill on first phase |
| `tasks/{task-name}/.repl-assets/annotations.js` | Shared annotation widget, copied from the skill on first phase |

## Phase 0: One-time setup (first phase only)

Before generating any HTML, do this once per task:

1. Create `tasks/{task-name}/.repl-assets/` if it doesn't already exist
2. Copy `skills/plan-repl-html/assets/style.css` to `tasks/{task-name}/.repl-assets/style.css`
3. Copy `skills/plan-repl-html/assets/annotations.js` to `tasks/{task-name}/.repl-assets/annotations.js`

The copy is a **snapshot**. Once a task has `.repl-assets/`, leave them
alone for the life of the task. If the skill's assets are updated mid-task,
in-flight tasks keep their original snapshot — preventing surprise visual
drift between annotation rounds. To pick up new assets, the user deletes
the task's `.repl-assets/` and asks you to regenerate (you re-copy and
re-render the phase pages).

Skip this step on subsequent phases of the same task — the assets are
already there.

## Scaffold mechanics

Two files in this skill's `templates/` directory drive what you generate:

- `templates/base.html` — the page shell. Head, `<link>` to the shared
  stylesheet, body with toolbar, and a `<script>` tag that loads the
  widget. Each phase reuses this verbatim and fills `<main>` with
  phase-specific content.
- `templates/examples.html` — one fully-populated example of every
  affordance the shared sheet provides. Read it to see the canonical
  markup for a section, callout, code-ref, risk table, timeline, todo
  list, or inline SVG. Copy the markup pattern, swap in your content,
  keep the classes and attribute names unchanged.

**What's already in the shared sheet** (so you know when to add a scoped
phase-specific `<style>` block and when not to):

- `section.annot` — the annotatable section shape, including the box the
  widget injects at the end
- `.callout` / `.callout-warning` / `.callout-question` — three callout
  flavors with a `.label` slot
- `.code-ref` — clickable, copyable inline code chips for file paths
- `<pre><code>` — multi-line code blocks
- `<table class="risks">` + `.pill.risk-high` / `.risk-med` / `.risk-low`
  — the risk table and its severity pills
- `<ol class="timeline">` — numbered phase cards (numbering on top-level
  `<li>` only)
- `<ul class="todos">` — checkbox list for `todo.html`
- `.grid-2` — two-column layout helper (use sparingly; not for
  annotation-target content)
- The hero header, sticky ToC, and toolbar all come from `base.html`
  unchanged

If a phase needs a visual element not in that list (a custom inventory
table, an extra pill variant, a step strip), add it to the empty `<style>`
block in the head — keep it short.

**What the widget builds for you, so you don't have to:**

- The sticky left-rail ToC auto-populates from every
  `<section class="annot">` with an `id`. Don't render `<ol id="toc-list">`
  entries by hand; just give your sections stable ids.
- The notes box at the end of each annotatable section is injected by the
  JS — don't include one in your markup.
- Anything outside an annotatable section (the hero's TL;DR, intro
  prose, an autonomous-run callout placed above the first section)
  won't appear in the ToC. That's fine — but if you want that content
  reachable from the ToC, wrap it in a `<section class="annot" id="…">`.

**What to preserve from the scaffold, what to fill in:**

- *Preserve:* the entire `<head>` (`<title>` aside), the `<link
  rel="stylesheet" href=".repl-assets/style.css">`, the `<body>` element's
  `data-task` / `data-phase` attributes (you'll fill those values), the
  `<div class="layout">` wrapper, `<nav class="toc">`, the
  `<div class="toolbar">` block, and the `<script src=".repl-assets/
  annotations.js">` tag. The widget depends on this markup unchanged.
- *Fill in:* the `<title>`, the `data-task` / `data-phase` attribute values,
  the `<header class="hero">` crumbs / `<h1>` / `<p class="tldr">`, and all
  content inside `<main>`. If the phase genuinely needs new visual elements
  the shared sheet doesn't cover (e.g. a custom inventory table), add a
  short, scoped CSS block inside the existing `<style>` element in the
  `<head>`. Keep additions minimal — most pages won't need any.
- *Remove:* the placeholder HTML comment block inside `<main>` (`<!-- Phase-
  specific sections go here... -->`) before saving the file. Don't ship the
  scaffold's own how-to comments in the final output.

**Picking `data-annot-id` values:** use descriptive slugs derived from the
section's noun phrase — `migration-rollout`, `auth-middleware-flow`,
`tradeoff-option-b`. Avoid positional ids (`section-3`) because exported
annotations reference these ids, and a re-ordering between turns silently
breaks the link between a note and the text it was attached to.

## Non-interactive mode

The phase prompts below tell you to ask the user a question or wait for the
user. When this skill is invoked from an evaluation, a CI job, or any context
without a live user (a parent agent driving subagents, for example), there's
no one to answer.

In that case: don't try to skip the question; just make a reasonable
judgment call, then write the assumption into the page itself as a callout
at the top of the relevant section:

```html
<div class="callout callout-question">
  <div class="label">Autonomous-run assumption</div>
  <p>No user was present to answer "<em>which areas should I research?</em>".
     I assumed the relevant code is X, Y, Z based on the task prompt. If a
     reviewer disagrees, they can annotate this section to redirect.</p>
</div>
```

This keeps the assumption visible in the artifact and annotatable, instead
of buried in a chat reply that doesn't exist. Apply the same pattern any
time the interactive workflow would have asked or waited.

When running non-interactively, also skip the user-facing "Transition"
lines below — they assume someone will open the file and follow up.

---

## Phase 1: Research

**Goal**: build genuine understanding, render it as a browsable HTML page the
user can navigate and annotate.

Ask: "What areas of the codebase should I research for this?"

Then explore — read the actual code, not file names. Cover the files that
will be touched, adjacent code, existing patterns, edge cases, tests. Quote
file paths and line numbers; the HTML can render `path:line` as a clickable
code chip that copies on click.

Structure `research.html` with these affordances HTML enables:

- **One section per area researched**, each with an `id` so the in-page
  table of contents links to it
- **A sticky left-rail ToC** for jumping between sections
- **File/line references rendered as styled code chips** — use the `.code-ref`
  class from the scaffold; the JS makes them copyable
- **Callouts for open questions** — use the `.callout-question` class
- **Callouts for potential pitfalls** — use the `.callout-warning` class
- **A "research summary" hero** at the top: one-paragraph TL;DR

Every section that the user might want to comment on gets a `data-annot-id`
attribute with a stable, descriptive id (e.g. `auth-middleware-flow`, not
`section-7`). Stable ids matter because exported annotations reference them,
and renaming an id between turns breaks the link between the note and the
text it was attached to.

**Transition** *(interactive mode only)*: "Research is in
`tasks/{task-name}/research.html` — open it in your browser, click sections
to annotate, hit *Export annotations* when you're done. Then tell me to
read them."

Wait for the user. In non-interactive mode, skip both the transition and
the wait — just continue to Phase 2.

---

## Phase 2: Planning

**Goal**: produce a detailed, annotatable HTML plan that uses every visual
affordance HTML offers where it actually helps.

Ask: "Ready for the plan — anything specific about how you want this
implemented?" Then write `plan.html`. Use the scaffold and add phase-specific
content. Lean into these patterns when they fit the work (not all will — only
use what genuinely helps):

**Annotation-target principle**: every piece of prose the user might want to
comment on individually should be its own `<section class="annot">` with a
stable `data-annot-id`. Don't bundle two prose items into a side-by-side
layout if a reviewer might want to react to one and not the other — the
notes box attaches to the whole section, and ambiguity about which half a
note refers to makes the annotation cycle worse than markdown was.

- **Phased timeline** as an ordered list of cards, each with an estimated
  size, the files it touches, and the rationale
- **Data-flow or sequence diagram** as inline SVG when the change involves
  multiple components talking to each other. Hand-author the SVG; don't
  reach for a library
- **Risk table** (`<table class="risks">`) with columns for risk,
  likelihood, mitigation. Likelihood gets a `.pill .risk-high` /
  `.risk-med` / `.risk-low` chip. Tight tabular data like this scans well
  and doesn't need per-row annotation
- **Trade-offs as a vertical list of sections, not a side-by-side grid.**
  Each trade-off is its own `<section class="annot">` with the option
  considered, the choice made, and the reasoning. Side-by-side grids
  collapse two pieces of prose into one annotatable target, which makes the
  annotation cycle worse than markdown was. Lists keep each rationale
  individually addressable
- **Before/after for refactors as stacked code blocks**, not side-by-side.
  Same reason: when "before" and "after" are sharing a row, the user can't
  comment on one without comment-on-the-other ambiguity

The plan should be detailed enough that implementation becomes mechanical.
Every annotatable section gets a `data-annot-id`.

**Transition** *(interactive mode only)*: "Plan is in
`tasks/{task-name}/plan.html`. Annotate in the browser, export, and tell
me to read them."

Wait for the user. In non-interactive mode, skip both the transition and
the wait.

---

## Phase 3: Annotation cycle

**Goal**: iterate on the plan (and research, and todo, when those come back
with annotations) until the user is satisfied.

The cycle:

1. User opens the relevant `.html`, clicks sections to add notes via the
   built-in widget, clicks *Export annotations*
2. The browser downloads `{task}.{phase}.annotations.json` — the user moves
   it next to the HTML at `tasks/{task-name}/{phase}.annotations.json` (or
   pastes the path)
3. You read the file, find each `{section_id, note}` pair, locate the
   matching `data-annot-id` in the HTML, update that section, and
   regenerate the page
4. After updating, delete or empty the annotations file so stale notes from
   the previous round don't re-apply. Also tell the user to click *Clear*
   in the toolbar so the browser's `localStorage` matches — otherwise the
   next export will resurrect the old notes
5. Repeat until the user exports no notes (or just tells you it's good)

Also: the `checks` field in the export carries todo-page checkbox state.
Ignore it during the annotation cycle for `research.html` and `plan.html`;
only `todo.html` exports use it meaningfully.

### Annotation export format

The widget exports this shape — keep it stable, the JS depends on it:

```json
{
  "task": "task-name",
  "phase": "plan",
  "exported_at": "2026-05-11T20:44:00Z",
  "annotations": [
    {
      "section_id": "auth-middleware-flow",
      "section_excerpt": "First ~120 chars of the section, for context",
      "note": "the user's note text, may be multiline"
    }
  ],
  "checks": { "todo-1": true, "todo-2": false }
}
```

The `checks` map is only populated by `todo.html`; for the other phases it
will be present but empty.

When addressing a note:

- Update the section the note targeted. If the note disagreed with you and
  you stand by your call, respond in chat before changing the HTML — same
  rule as `plan-repl`'s markdown notes
- Don't reword sections the user didn't annotate; minimize churn so a diff
  between revisions is readable
- If `section_id` doesn't match any current `data-annot-id` (because the
  HTML was regenerated and ids shifted), surface it: don't silently drop
  the note

Expect several rounds. This is the highest-leverage phase — the same as in
`plan-repl`. The HTML widget exists to make a round faster, not to compress
the number of rounds.

---

## Phase 4: Task breakdown

**Goal**: generate `todo.html` from the approved plan.

The breakdown is a checkbox grid grouped by plan phase. Two design choices
to lean into here:

- **Checkboxes are the source of truth.** The widget persists checkbox
  state to `localStorage` keyed by task name, and exports it as part of
  `annotations.json` when the user hits export. On resume, you read the
  exported state to figure out where implementation is — not by inferring
  from git
- **Each task links back to the plan section it came from** (via anchor
  links into `plan.html`). Cross-document linking is one of the cheap wins
  HTML gives you

Same structure as `plan-repl`: one group per plan phase, each task small
enough to be a single clear change.

After generating, stop and wait for the user to sign off before
implementation. Don't auto-proceed.

---

## Phase 5: Implementation

**Goal**: execute the approved plan. Mechanical work.

Work through `todo.html` in order. After each task, regenerate the page
with the corresponding checkbox checked (or instruct the user to check it
in the browser, then export so you can read state back — either is fine,
agree with the user up front which loop you're using).

Same guard rails as `plan-repl`:

- Don't add features that aren't in the plan
- Don't refactor surrounding code
- If you discover the plan needs to change, stop and discuss

---

## Notes for evaluation (this is an experiment)

This skill exists to find out where HTML output earns its keep and where it
gets in the way. While running through a real task with it, keep a running
ledger — surface these to the user when relevant, not as a final report
dump:

- **What HTML made easier than markdown.** Concrete moments: "the timeline
  for this 3-phase rollout was much easier to scan in HTML than as a
  bulleted list."
- **What HTML made harder.** "Regenerating the page after each annotation
  pass is heavier than editing a markdown file in place."
- **Where the annotation widget felt awkward.** Section ids that didn't
  survive a regeneration, notes that wanted to attach to a sub-element,
  the export-and-move-file dance.
- **What you'd change in a v2.** Be specific. "Live-saving annotations to a
  watched file would remove the manual export step."

The point isn't to be optimistic about the format. It's to learn fast.

---

## Things not to do

- **Don't** treat HTML as a way to skip planning rigor. The format is
  prettier; the discipline is the same. A flashy timeline doesn't make up
  for a vague plan.
- **Don't** invent your own annotation UI per page. The `templates/base.html`
  scaffold ships the widget; every generated page must include it
  unchanged, or the export format drifts and round-trips break.
- **Don't** silently regenerate annotated sections you didn't touch — the
  user expects diffs to be reviewable. Minimize churn.
- **Don't** load assets over the network in generated HTML. The shared CSS
  and JS already sit alongside the page in `.repl-assets/`; anything beyond
  that needs to be inlined into the phase-specific `<style>` block. The
  goal is that a `tasks/{task-name}/` folder can be opened on any machine
  with a browser and zero setup.
- **Don't** edit the shared `.repl-assets/style.css` or `annotations.js`
  inside a task folder once they've been snapshotted. Those files are the
  task's locked-in baseline; if behavior needs to change, update the
  skill's `assets/` and have the user delete the task's `.repl-assets/` so
  the next phase re-copies the new version. Editing the snapshot in place
  invites drift between what the SKILL.md documents and what the page
  actually does.
- **Don't** auto-suggest this skill for tasks that aren't an explicit
  experiment in HTML output. `plan-repl` is the default workflow; this is
  the lab variant.
