---
name: diataxis-reference
description: >-
  Write, expand, or audit reference documentation — information-oriented
  technical description in the Diátaxis sense: austere, accurate, consistent
  facts about the machinery, consulted while working. Use whenever the user
  wants API docs, a configuration or parameter listing, CLI or command
  documentation, an options table, schema or data-model docs, error-code
  catalogs, environment-variable docs, or any "document what X is / what
  settings exist" request — even if they never say "reference". Also loaded
  by the `diataxis` router when the compass points to cognition + application:
  the reader needs *facts to consult* while *getting work done*. If the
  content is mostly why-and-context discussion, that's `diataxis-explanation`;
  if it directs the reader's actions step by step, that's `diataxis-how-to`.
  When the type is in doubt or mixed, consult the `diataxis` skill first.
---

# diataxis-reference

Reference is **a map of the machinery**. A map tells you what you need to know about the territory without your having to go out and survey it yourself — and like a map, reference is neutral: it doesn't care what the reader is doing. The same chart serves the navigator plotting a course and the judge investigating a wreck. Diátaxis places reference at *cognition* + *application*: propositional knowledge, consulted in the middle of work.

What the working reader needs from it is **truth and certainty** — a firm platform to stand on. That single need dictates the style: austere, uncompromising, consistent, complete.

## Check you're writing the right thing

- The content **discusses, contextualizes, justifies** — answers "why" → `diataxis-explanation`. Heuristics from the boundary: if it's boring and unmemorable, it's probably reference; lists and tables almost always belong in reference; anything you'd introduce with "can you tell me more about…" leans explanation. The real test — consulted *while actively working* → reference; read *away from the work* to understand → explanation.
- The content **directs action toward a goal** → `diataxis-how-to`.
- The content **walks a beginner through a lesson** → `diataxis-tutorial`.
- Mixed or unclear → step back to the `diataxis` router and run the compass.

## Step 1 — Let the machinery dictate the structure

The structure of reference documentation should mirror the structure of the product, the way a map mirrors the territory. If a method belongs to a class inside a module, the documentation shows that same nesting. The reader navigates the docs by their knowledge of the thing itself — so before writing, identify the product's own architecture and organize by it, not by task, audience, or narrative.

For anything derivable from the code (signatures, defaults, options, types), read the source and derive it — never write a fact about the machinery you haven't verified against the machinery.

## Step 2 — Adopt a pattern, then never deviate

Reference is useful when it is consistent: the reader should always find the same kind of information in the same place in the same form. Decide the standard entry shape up front — e.g., for each option: name, type, default, effect, constraints — and apply it uniformly. One voice throughout; a reference that changes register between entries makes the reader re-learn how to read it at every entry.

If auditing an existing reference, infer the dominant pattern first and bring outliers into line with it rather than inventing a new one.

## Step 3 — Describe. Do nothing else.

Neutral description is the key imperative. State facts, plainly:

- Flat declaratives: "Django's default logging configuration inherits Python's defaults."
- Plain enumeration: "Sub-commands are: a, b, c, d, e, f."
- Normative statements where the machinery imposes them, stated as fact, not persuasion: "You must use a. Never d while b is active."
- Warnings the same way — factual, in the entry they belong to.

Usage examples are welcome and often the fastest way to convey a fact — but keep them illustrative. An example that starts narrating steps has become instruction; one that starts justifying the design has become explanation.

## Step 4 — The drift checklist

Use this on your own draft, and as the audit lens when the `diataxis` router sends an existing reference here. An audit invocation runs only this step — skip Steps 1–3 and report findings without editing; edits wait for the router's confirmation gate. The repair move is usually **relocation, not deletion**.

- Explanatory asides — rationale, history, design discussion sprinkled between entries → consolidate into an explanation article and link; digressions interrupt and obscure the reference, and the fragments never add up to a proper explanation either.
- Instructional creep — recipes and step sequences inside entries → relocate to a how-to guide; link.
- Examples grown too expansive → trim back to illustration; move the surplus where it belongs.
- Inconsistent entry shapes, register shifts, creative vocabulary → normalize to the standard pattern.
- Structure organized by narrative or audience instead of by the machinery → restructure to mirror the product.
- Marketing or opinion ("the powerful x subsystem") → delete; reference carries no advocacy.
- Unverified or stale facts → check against the source; a reference the reader can't trust is worse than none.

## Things not to do

- **Don't** instruct, explain, discuss, or opine. Describe — and link outward for everything else.
- **Don't** organize by use case. That's a how-to guide's job; the machinery's own structure is the reference's index.
- **Don't** vary the pattern for interest's sake. Boring and predictable is the virtue here.
- **Don't** rely solely on auto-generated output. Generated docs inherit the code's structure but still need curation, examples, and accuracy checks.
- **Don't** state a fact you haven't verified against the product.
