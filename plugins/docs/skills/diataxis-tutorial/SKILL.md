---
name: diataxis-tutorial
description: >-
  Write, expand, or audit a tutorial — learning-oriented documentation in the
  Diátaxis sense: a lesson that takes a beginner through a guided, hands-on
  experience to build skill and confidence, where the artifact produced along
  the way is not the point. Use whenever the user wants a "getting started"
  guide, onboarding walkthrough, "first steps with X", intro lesson, learning
  exercise, workshop material, or asks to "teach someone" a tool, API, or
  codebase by doing — even if they never say "tutorial". Also loaded by the
  `diataxis` router when the compass points to action + acquisition: the
  reader will *do* something in order to *learn*. If the reader is an
  already-competent practitioner trying to get a real job done, that's
  `diataxis-how-to` instead; when the type is in doubt or mixed, consult the
  `diataxis` skill first.
---

# diataxis-tutorial

A tutorial is a **lesson**. The reader learns by doing, under your direction — like teaching a child to cook. Success is measured by the skill and confidence the learner acquires, not by the quality of the thing they made along the way. Diátaxis places tutorials at *action* + *acquisition*: practical steps, in service of study.

The hard constraint shaping everything below: the teacher is responsible for the learner's success, yet is "required to be present, but condemned to be absent." The text alone must anticipate everything, because you won't be there when a step goes wrong.

## Check you're writing the right thing

Before starting, confirm the compass really points here:

- The reader is **already competent** and wants to accomplish a real task → `diataxis-how-to`.
- The content **describes the machinery** — options, APIs, facts to consult mid-work → `diataxis-reference`.
- The reader wants to **understand why** — background, design rationale, context → `diataxis-explanation`.
- Mixed or unclear → step back to the `diataxis` router and run the compass.

Difficulty is not the axis: a tutorial can cover something complex, and a how-to guide can cover something basic. The axis is study vs. work.

## Step 1 — Establish the lesson

Pin down, asking the user where the material doesn't answer:

1. **Who is the learner?** What can they already do? A tutorial familiarizes the learner with the basics — assume little, and state the true prerequisites explicitly.
2. **What will they be able to do afterward?** Name a meaningful capability, not a topic. This becomes the opening promise: "In this tutorial, we will…"
3. **What's the environment?** A tutorial happens in a contrived, controlled setting the author chose — safe, reversible, and reliable. Decide what that setup is and make getting into it the first steps.

## Step 2 — Design the path

Design the sequence of actions before writing prose:

- **One path, no choices.** Alternatives and options are for how-to guides and reference. Every fork you offer a learner is a distraction and a chance to fail.
- **A visible result early, then visible results all along.** Each step should produce something the learner can see and recognize as meaningful. The feeling of purpose → action → result is where learning happens.
- **End somewhere usefully complete**, and close the promise the opening made.
- **Every step must work — every time.** The tutorial earns confidence through perfect reliability, and one step that doesn't do what the text promised destroys it. For anything executable, run the steps yourself and capture real output; never show output you haven't verified. When you genuinely can't execute the steps (no environment, no credentials, a system you can't reach), don't fabricate terminal output to fake verification — ground every concrete claim in a source you did read, narrate expected results in prose, and tell the user which steps remain unverified so they can run them.

## Step 3 — Write it

The first rule of teaching: **don't try to teach.** Give the learner things to do, and let the doing carry the lesson.

- Write in first-person plural — "we" — affirming the tutor–learner relationship.
- Open by showing where we're going: "In this tutorial, we will create and deploy…"
- Give unambiguous imperatives in strict order: "First, do x. Now, do y."
- Maintain the narrative of the expected: tell the learner what they'll see, and show real sample output. "You will notice that…" "The output should look something like…"
- Point out what deserves attention: "Notice that…", "Remember that…", "Let's check…"
- **Ruthlessly minimize explanation.** If a line of reasoning is unavoidable, keep it to a sentence — "We're using HTTPS because it's more secure" — and link to the explanation article for later. More than that steals attention from the doing.
- Stay concrete and particular. Learning moves from the concrete toward the general — generalizing is the reader's later step, not your job here.
- Permit and encourage repetition; sometimes it's the only teacher.
- Close by acknowledging what the learner has accomplished: "You have built a…"

## Step 4 — The drift checklist

Use this when reviewing your own draft, and as the audit lens when the `diataxis` router sends an existing tutorial here. An audit invocation runs only this step — skip Steps 1–3 and report findings without editing; edits wait for explicit confirmation — the router's gate, or the user's when invoked directly. The audit's repair move is usually **relocation, not deletion** — the content is fine, it just lives in the wrong place.

- Explanation running past a sentence → move it to an explanation article; leave a one-line note and a link.
- Options or alternative paths offered → cut to the single path; alternatives belong in how-to guides or reference.
- Abstract or general statements → replace with the concrete instance in front of the learner.
- Steps whose result the learner can't see → surface the result, or question the step.
- Teaching by telling — paragraphs of theory before the next action → convert to doing, or relocate.
- Assumed knowledge gaps — a step a genuine beginner couldn't complete → fill in or add to prerequisites.
- Promised output that may not match reality → verify by running it.

## Things not to do

- **Don't** explain, beyond a linked one-liner. A tutorial is not the place for explanation.
- **Don't** offer choices. One path.
- **Don't** aim for completeness. The lesson's scope is the author's choice; comprehensiveness belongs to reference.
- **Don't** judge the tutorial by the artifact it builds. A driving lesson exists to make a driver, not to get from A to B.
- **Don't** ship a step you haven't verified works exactly as written.
