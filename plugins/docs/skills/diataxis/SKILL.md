---
name: diataxis
description: >-
  Router for documentation work under the Diátaxis methodology. Use whenever
  the user wants to write, add to, expand, reorganize, or audit documentation
  — "write docs for X", "document this feature", "add a page about",
  "improve our README", "does this doc work", "audit our docs", "--audit" —
  or mentions Diátaxis, the compass, or a documentation type when no single
  type skill is the obvious match. Applies the compass (action or cognition?
  acquisition or application?) to classify the reader's need, then hands off
  to diataxis-tutorial, diataxis-how-to, diataxis-reference, or
  diataxis-explanation. When the user points at existing docs or supplies
  paths, assume the work is adding to or expanding those articles. With
  --audit, runs an improvement pass instead: classify each unit, run the
  matching type's drift checklist, and propose relocations and splits that
  fit the docs to the model without rewriting their substance. Prefer this
  router over a type skill whenever the type isn't already certain.
---

# diataxis

Diátaxis holds that documentation answers four distinct user needs — **tutorials** (learning), **how-to guides** (goals), **reference** (information), **explanation** (understanding) — and that a large share of documentation problems are one piece of content trying to serve two needs at once. Each unit of content should be one of the four types.

How to hold it: Diátaxis is **a guide, not a plan** — a map for checking that you're in the right place and heading the right way, not a structure you must complete, a specification, or railway tracks. Structure is an *outcome*: documentation assumes the Diátaxis shape because it has been improved, not the other way around. So never open by carving out four sections.

This skill is the router. It figures out which need the work in front of you serves, then hands off to the matching type skill, where the craft rules live.

## The compass

Two questions classify any piece of content — proposed or existing:

1. Does it inform **action** (practical steps, doing) or **cognition** (propositional knowledge, thinking)?
2. Does it serve the reader's **acquisition** of skill (study) or its **application** (work)?

| If the content… | …and serves the user's… | …then it must belong to… |
| --------------- | ----------------------- | ------------------------ |
| informs action | acquisition of skill | a tutorial |
| informs action | application of skill | a how-to guide |
| informs cognition | application of skill | reference |
| informs cognition | acquisition of skill | explanation |

Use the terms flexibly — don't fixate on the exact names. The questions work at any scale (a doc set, a page, a paragraph, a sentence) and in any phrasing: "is the reader at study or at work here?", "do they need to do or to know?" The compass earns its keep precisely when something feels off but you can't yet say why — it forces you to stop and reconsider.

When intuition is shaky on the cognition side: if it's boring and unmemorable, it's probably reference; lists and tables almost always are. If you'd read it in the bath, it's explanation. And on the action side, the axis is study vs. work — never basic vs. advanced. A tutorial can be complex; a how-to guide can be basic.

## Mode selection

- **Default — writing.** The user wants documentation written, added to, or expanded. Follow "Writing mode" below.
- **Audit** — the user wants existing documentation examined, whether via a literal `--audit` or phrasing like "audit our docs" or "does this doc work". An audit is an improvement/refactoring pass: make the docs fit the Diátaxis model better, without necessarily changing what they say. Follow "Audit mode" below.

## Writing mode

### Step 1 — Establish the material and where it lives

If the user mentioned existing documentation or gave paths, read those articles first — the default assumption is that this work **adds to or expands them**, so establish what type each already is (or is trying to be) before writing a word. For new content, find where it will live among any existing docs, and what neighbors it will link to.

Expanding an article never overrides the compass. When Step 2 classifies the requested material as a different type than the article it was aimed at, "expanding" means expanding the article's *family*: the material lands in a linked sibling of the right type, and the original gets at most a one-clause pointer. The compass decides the type; the user's path only decides the neighborhood.

### Step 2 — Run the compass

Classify what the user actually needs written. If their request doesn't settle both questions, ask — one question, in reader terms ("is this for someone learning the system, or someone mid-task trying to get something done?") rather than in Diátaxis jargon.

A request that spans types is normal, not a failure: "document the deploy pipeline" may need a how-to guide *and* a reference page *and* a paragraph of explanation. Split it into pieces, one type each, and link them — splitting along the straddled axis is the standard repair, in writing as in auditing.

### Step 3 — Hand off

Invoke the matching type skill(s) via the Skill tool — `docs:diataxis-tutorial`, `docs:diataxis-how-to`, `docs:diataxis-reference`, `docs:diataxis-explanation` — passing along what Steps 1–2 established: the reader, the classification, the target file(s), and the neighbors to link. For multi-type work, handle one piece at a time to completion rather than drafting everything at once; each finished piece sharpens the next.

## Audit mode

### Step 1 — Determine the target

Establish which doc(s) the user wants examined — a file, a directory, a whole docs set. If unclear, ask. Prefer a scope you can actually finish: Diátaxis works by small, completed improvements, not surveys that trail off.

### Step 2 — Classify each unit of content

Read the target docs and run the compass over each unit. The unit is whatever holds one type: usually a page, but for container documents it's the **section** — a README whose overview, setup walkthrough, and options table sit side by side is applying Diátaxis sectionally, and that's legitimate. Judge each section on its own; the finding "this file is four types stacked" is only a problem if the sections themselves are muddled or the readers can't find their part. A title and a sentence or two of framing at the top of a page isn't a unit — don't classify it, and don't invent drift findings about it.

When a unit's classification is genuinely ambiguous — it could be serving either of two needs, and the answer changes the findings — ask the user, the same way writing mode does: one question, in reader terms. Record the answer in the report rather than silently picking a side.

For each unit, record: what user need it serves (or is trying to), which type that makes it, and where it blurs — explanation inside a tutorial, teaching inside a how-to, recipes inside reference, procedure inside explanation.

### Step 3 — Run the type checklists

For each type present, invoke the matching type skill, telling it this is an audit: it applies only its drift checklist — no drafting, no edits. The checklists are the per-type audit lens; this router only contributes the classification and the cross-cutting findings.

### Step 4 — Report, then stop

Produce a findings report before touching anything:

- Per unit: its type, how well it serves that need, and the specific drift found.
- Proposed moves, smallest first. The repair vocabulary is **relocate, split, link, relabel** — plus outright removal for the rare content that belongs nowhere (trivial guidance, marketing advocacy). An audit makes content fit the model better, it doesn't rewrite the substance. Flag "this paragraph is explanation living in a tutorial; move it to X and leave a one-line link" rather than "rewrite this paragraph."
- Empty quadrants, as observations: sorting existing docs is the cheap half; noticing that a project has reference and how-tos but no tutorial and no written *why* is where the model pays. Usually it's the acquisition column that's missing.
- Functional-quality problems the sorting exposed (a gap in reference coverage, a step readers are left to figure out) — Diátaxis surfaces these but they're separate findings, not type-drift.

Then **stop and confirm** which moves to apply. On approval, apply them one at a time, each left complete — not as one big-bang restructure.

## Working method

For any mode: work in single small improvements — each thing done reveals the next. Don't tear a mess down to start over, and don't work on the big picture; small steps arrive there on their own. Documentation is never finished, but at every stage it can be *complete*: useful, healthy, ready for its next step.

## Things not to do

- **Don't** create empty tutorial/how-to/reference/explanation scaffolding and then fill it. Structure emerges from improved content, never the reverse.
- **Don't** force one-file-one-type on container docs. A README applying Diátaxis per-section is the model working, not a violation.
- **Don't** demand exactly four top-level boxes. Larger doc sets may nest (how-to guides grouped by platform) or interleave audiences — fine, as long as no unit muddles its forms and purposes.
- **Don't** rewrite substance in an audit. Relocate, split, link, relabel — delete only what a type checklist says belongs nowhere; recast wording only where it's doing the wrong type's job in place.
- **Don't** confuse fitting the model with being good. Diátaxis exposes functional gaps — stale facts, missing coverage — but conformance doesn't guarantee quality. Report both, separately.
- **Don't** wait for a full understanding of the doc set before improving something. Understanding comes from working on it.
