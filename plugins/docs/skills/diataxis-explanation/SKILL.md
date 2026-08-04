---
name: diataxis-explanation
description: >-
  Write, expand, or audit explanation — understanding-oriented documentation
  in the Diátaxis sense: discursive discussion that deepens the reader's grasp
  of a topic, read away from the work itself. Use whenever the user wants an
  architecture overview, design-rationale or "why did we build it this way"
  doc, concept guide, background or theory piece, ADR-style context, a
  "philosophy of X" or "about X" article, or asks to capture the reasoning
  behind a decision — even if they never say "explanation". Also loaded by
  the `diataxis` router when the compass points to cognition + acquisition:
  the reader wants to *understand*, as *study*. If the content is facts to
  consult mid-work, that's `diataxis-reference`; if it directs a task, that's
  `diataxis-how-to`. When the type is in doubt or mixed, consult the
  `diataxis` skill first.
---

# diataxis-explanation

Explanation is **discussion that permits reflection** — the documentation a practitioner reads away from the keyboard, the way a cook reads *On Food and Cooking*: not to follow a recipe, but to understand the craft in a way that changes their practice. It answers the question "can you tell me about…?" Diátaxis places explanation at *cognition* + *acquisition*: propositional knowledge, in service of study.

Its characteristic problem isn't being written badly — it's not being written at all. The *why* of a system ends up scattered through commit messages, review threads, and hallway conversations, because explanation has no obvious owner. Writing it down as a first-class document is most of the battle.

## Check you're writing the right thing

- The content is **facts consulted while working** — options, parameters, structures → `diataxis-reference`. The boundary test: reference serves the reader mid-work; explanation serves the reader who has stepped back. Lists and tables usually mean reference; "tell me more about…" means explanation.
- The content **directs a task** → `diataxis-how-to`.
- The content **teaches a beginner by doing** → `diataxis-tutorial`.
- Mixed or unclear → step back to the `diataxis` router and run the compass.

## Step 1 — Frame the "about"

An explanation's title carries an implicit *about*: "About user authentication," "On caching strategy," "Why the scheduler is cooperative." Fix the topic and its altitude first:

1. **Name the subject** as a topic, not a task.
2. **Choose the bounds.** Explanation may range — history, alternatives, tradeoffs — but around a bounded subject. If the scope is "everything," it's several articles.
3. **Know the reader's question.** What understanding are they missing that this article supplies? Design decisions, constraints, and history the code can't show are the highest-value material.

## Step 2 — Gather the why

Explanation is the one type whose raw material is mostly *not* in the artifact. Mine where the reasoning actually lives: design docs, ADRs, commit messages, PR discussions, issue threads, the user's own memory. Interview the user for what nothing else records — "why not the obvious alternative?" is usually the most productive question. Then verify any claims about the current system against the current system.

## Step 3 — Write it

Explanation has permissions the other three types deny — use them:

- **Make connections.** Link the subject to related topics, to the rest of the system, to things outside it entirely. Weaving fragments into a coherent web is the job.
- **Provide context.** Design decisions, historical reasons, technical constraints, with concrete examples: "The reason for x is because historically, y…"
- **Approach from multiple directions.** Explanation may circle its subject; analogy is a legitimate tool: "An x in system y is analogous to a w in system z. However…"
- **Have opinions.** All human knowledge is invested with opinion, and explanation is where it's admitted: "W is better than z, because…" Weigh alternatives honestly: "Some users prefer w (because z). This can be a good approach, but…"
- **Stay off the tools.** The reader is reflecting, not executing. The moment the prose says "now run…", it has drifted.

## Step 4 — The drift checklist

Use this on your own draft, and as the audit lens when the `diataxis` router sends an existing explanation here. An audit invocation runs only this step — skip Steps 1–3 and report findings without editing; edits wait for the router's confirmation gate. The repair move is usually **relocation — or consolidation**.

- Instruction or procedure creeping in → relocate to a how-to guide or tutorial; link.
- Dry enumerations of options, parameters, structures → relocate to reference; link.
- The inverse problem — explanatory fragments scattered across tutorials, how-tos, and reference entries elsewhere in the doc set → gather them *into* this article and leave links behind. Consolidation is explanation's distinctive audit move.
- Opinion presented as neutral fact without the reasoning → either supply the why or mark the perspective.
- Unbounded scope, three subjects in one article → split along topic lines.
- Claims about the system that no longer match the system → verify and update; rationale docs go stale silently.

## Things not to do

- **Don't** instruct. No steps, no commands to run.
- **Don't** turn into a catalog. Exhaustive facts belong in reference.
- **Don't** feign neutrality. Reference must be neutral; explanation earns trust by showing its reasoning, alternatives and all.
- **Don't** leave the why unwritten because it feels "obvious to the team." That's exactly the knowledge that leaves when people do.
