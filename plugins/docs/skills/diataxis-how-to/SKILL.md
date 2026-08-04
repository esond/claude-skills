---
name: diataxis-how-to
description: >-
  Write, expand, or audit a how-to guide — goal-oriented documentation in the
  Diátaxis sense: directions that help an already-competent reader accomplish
  a specific real-world task. Use whenever the user wants a "how to X" doc, a
  runbook, playbook, recipe, troubleshooting guide, setup/configuration/
  migration/deployment/integration instructions, or step-by-step directions
  for practitioners — even if they never say "how-to guide". Also loaded by
  the `diataxis` router when the compass points to action + application: the
  reader will *do* something to *get work done*. If the reader is a beginner
  who needs to learn by doing in a safe setting, that's `diataxis-tutorial`
  instead; if the content mostly enumerates options and facts, that's
  `diataxis-reference`. When the type is in doubt or mixed, consult the
  `diataxis` skill first.
---

# diataxis-how-to

A how-to guide is a **recipe**: it defines exactly what will be achieved and directs an already-competent reader through achieving it. A recipe doesn't teach you to cook — it assumes basic competence and helps you get tonight's dinner made. Diátaxis places how-to guides at *action* + *application*: practical steps, in service of work.

The reader is in the middle of doing their job. Everything that isn't helping them finish is in their way.

## Check you're writing the right thing

- The reader is a **beginner learning by doing**, in a setting you control → `diataxis-tutorial`. The axis is study vs. work, not easy vs. hard — a how-to can be basic and a tutorial complex.
- The content is mostly **facts, options, parameters to consult** → `diataxis-reference`.
- The reader wants **background and why** → `diataxis-explanation`.
- Mixed or unclear → step back to the `diataxis` router and run the compass.

A tutorial answers "teach me to cook"; a how-to answers "how do I make this tonight, for eight, with no oven?" And unlike a tutorial, the how-to cannot promise safety or control the setting — the user is in the real world and responsible for their own outcome, so flag the hazards where they occur.

## Step 1 — Define the goal

1. **Name the real-world task.** A how-to guide answers a question only a user in the real world asks: bounded, specific, practical. "How to build a web application" is not it (that's a curriculum); "how to integrate application performance monitoring" is.
2. **Title it as the goal.** "How to <accomplish X>" — the title should say exactly what the guide shows. Users find guides by matching titles against their problem.
3. **Decide the boundaries.** Start and end in a reasonable, meaningful place. What can you assume is already true? What's out of scope? Assumed competence is the how-to's licence to be brief — state the assumptions and then honor them.

## Step 2 — Design the sequence

- **Order steps by the user's activity**, not the machinery's layout. Write from the perspective of the person doing the work: what do *they* do next, with the tools at hand?
- **Seek flow.** Each step should set up the next; minimize context-switching between tools, files, and mental modes.
- **Real tasks fork.** Unlike a tutorial's single path, a how-to may branch on the user's situation — conditionals and multiple entry or exit points are fine when the real problem has that shape. Don't force linearity that isn't there; don't invent branches that are.
- **Omit the unnecessary.** Practical usability beats completeness. Anything exhaustive — full option lists, every parameter — gets a link to reference instead of a place in the guide.

## Step 3 — Write it

- Open with the contract: "This guide shows you how to…"
- Use conditional imperatives keyed to the user's goal: "If you want x, do y." "To achieve w, do z."
- Address the reader as a competent adult. No teaching, no "as you may know…", no re-deriving basics.
- Push detail outward: "Refer to the x reference for the full list of options."
- Keep explanation out of the path. If a step needs a reason, one clause — the middle of a task is the one time the reader doesn't want a lecture. Link to the explanation article for later.

## Step 4 — The drift checklist

Use this on your own draft, and as the audit lens when the `diataxis` router sends an existing how-to guide here. An audit invocation runs only this step — skip Steps 1–3 and report findings without editing; edits wait for the router's confirmation gate. The repair move is usually **relocation, not deletion**.

- Trivial guidance — "to shut off the water, turn the tap clockwise" — telling a competent reader what they already know → cut.
- Teaching, background, history, or concept-building mid-task → relocate to explanation or a tutorial, leaving the one-clause statement plus a link in place. Relocation keeps a stub — don't strip the step of its naming sentence and leave a bare hole.
- Exhaustive listings of options or parameters → relocate to reference; link.
- Tutorial creep — comprehensive end-to-end coverage, contrived setup, hand-holding through basics → re-scope to the real task, or split a genuine tutorial out.
- A vague title ("Monitoring", "Deployment notes") → rename to "How to <goal>".
- Steps ordered by the system's structure rather than the user's workflow → reorder around the activity.
- Rigid linearity where the real task branches (or branches the task doesn't have) → match the sequence to reality.

## Things not to do

- **Don't** teach. Assume competence; the guide serves work, not study.
- **Don't** explain in the path. Link and move on.
- **Don't** aim for completeness. Omit the unnecessary; reference exists for the rest.
- **Don't** describe the machinery for its own sake. Every sentence serves the user's next action.
- **Don't** promise the safety of a tutorial. The user is in the real world — flag destructive or irreversible steps where they occur.
