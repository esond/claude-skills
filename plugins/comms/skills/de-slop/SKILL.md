---
name: de-slop
description: >-
  Deep-strip the tells of AI writing (claudisms) from a draft while keeping its
  meaning and the writer's voice intact — the mirror image of the dehumanizer
  skill, which adds them. Sweeps the draft against the living claudisms banlist
  at claudisms.ai (em dashes, "not just X, it's Y," delve / tapestry /
  testament / robust, "worth noting," crowned superlatives, signposting, rule
  of three) plus the constructions a text search can't catch. Use this skill
  whenever the user wants AI tells removed from writing — phrasings like
  "de-slop this," "strip the claudisms," "remove the AI tells," "humanize
  this," "scrub the AI out of this," "make this sound like I wrote it," "this
  reads like ChatGPT wrote it," or "would this pass as human?" — even if they
  never say "de-slop." This is the deep, deliberate pass for writing that
  ships under the user's name. It is not for making text look more
  AI-generated — that is the dehumanizer skill.
---

# De-slop: Strip the AI Tells from Writing

You take a draft that reads like a model wrote it and return one that reads
like the person whose name is on it wrote it. The animating idea comes from
[Your Name Is Still on It](https://wespomeroy.substack.com/p/your-name-is-still-on-it):
when writing ships under someone's name, every AI fingerprint left in it
spends that person's credibility. Your job is to find every tell and remove
it — without touching what the draft says or who it sounds like.

This is a deep pass, not a quick polish. Expect to read the draft several
times and to work through an inventory of tells systematically. That cost is
the point: the user reaches for this skill when the writing matters.

## Two hard rules: keep the meaning, keep the voice

Everything else is judgment; these two are not.

**1. The meaning.** The reader of the cleaned draft must walk away knowing
exactly what the reader of the original would have — same facts, same claims,
same numbers, same names, same asks, same conclusions. Stripping a tell never
justifies dropping the content it was wrapped around. If a banned phrase is
carrying a real point ("it's worth noting the deadline moved" carries "the
deadline moved"), keep the point and shed the wrapper.

**2. The voice.** The goal is the writer's voice, not a third voice that is
merely "plain." Slop-stripping has its own failure mode: sanding every
sentence into beige, uniform prose — which is itself an AI tell. Whatever
personality, humor, bluntness, or rhythm survives in the original is the
signal; amplify it by clearing the slop away from it. When the draft gives
you samples of how the writer actually sounds (an unslopped paragraph, a
distinctive turn of phrase), match those. When it doesn't, prefer the
plainest direct statement and flag places where only the author can supply
the voice.

## Step 1: Load the inventory

Download the living banlist **verbatim**: save
https://claudisms.ai/claudisms.md to a temp file and read it — for example
`curl -sL https://claudisms.ai/claudisms.md -o <scratchpad>/claudisms.md`,
then read that file. Do not use a web-fetch tool that answers a prompt
about the page: those summarize, and a condensed inventory silently drops
entries from your sweep (in testing, the banned adjective "real" and
metaphorical "quieter" slipped through exactly this way).

The list holds 80+ confirmed claudisms plus structural tics, register tics,
and spoken-word tells, each with the reasoning and preferred rewrites — and
it grows, which is why the skill downloads it live rather than bundling a
copy.

If the download fails, say so in one line and proceed using the distilled
checklist at the bottom of this file. Do not stop — the checklist covers the
highest-signal families.

One caution: the inventory encodes a few of its author's house-style
conventions alongside the genuine AI tells — pieces are "articles" not
"essays," em dashes become spaced hyphens (` - `). Strip the *tell* (the em
dash, the tic), but choose replacements that fit **this** user's writing, not
the list author's. An em dash can become a comma, a period, parentheses, or a
spaced hyphen — whichever the surrounding voice would pick.

## Step 2: Read the draft and note what must survive

Before changing anything, read the whole draft and write down:

- Every fact, claim, number, name, quote, ask, and conclusion — this is your
  meaning checklist for the end.
- The register: is it a blog post, a LinkedIn post, an email, a Slack
  message, a doc? Formal or casual? Warm or dry? The output must stay in the
  same register and roughly the same length — de-slopping compresses a
  little (filler leaves), but a draft that comes back half as long has lost
  content, not slop.
- Any lines that already sound like a person. Those are your voice anchors —
  leave them alone and tune the rest toward them.

## Step 3: Sweep for tells — three passes

A single read misses too much, and the inventory itself warns why: many
claudisms are *constructions*, not phrases, so a literal match on the listed
wording catches only the examples someone already flagged. Make three
distinct passes.

**Pass 1 — phrase sweep.** Walk the inventory and search the draft for each
listed word and phrase. This is mechanical; be exhaustive. Mark every hit.

**Pass 2 — construction sweep, by eye.** Reread looking for the *shapes*
the list describes, with any words in the slots:

- Negative parallelism: "it's not just X, it's Y," "this isn't about X. It's
  about Y." The single most-cited AI tell.
- Totalizers and crowned superlatives: "the whole [anything]," "the only
  [X] that [verb]," "the most [X]," "the one that [verb]," "the best thing
  you can do."
- Value-claim filler: any "worth [X]," "this matters," "the useful thing,"
  "the right [X]" — telling the reader what to think of a thing instead of
  letting the thing show it.
- Pseudo-reflective journey framing: "sit with," "keep coming back to,"
  "where I landed," "what struck me," "I can't stop thinking about,"
  "the thing that got me."
- Placement and agency metaphors for abstractions: ideas that "live,"
  "hold," "carry," "compound," "ride along"; words "doing the work"; "the
  engine," "the shape of," "load-bearing," "the physics of."
- Invented observation and invented emotion: "most people I've talked to,"
  "everyone I've worked with," "hit a nerve," "stuck with me" — claims of
  experience or reaction that were never actually described.

**Pass 3 — structure and rhythm.** Zoom out from words to the draft's
skeleton:

- Signposting and throat-clearing: announcing points before making them,
  "Here's where it gets interesting," "Let's break it down," restating the
  question before answering it.
- Rule of three: adjectives, clauses, and examples forced into triples.
- Flattened syntax: every sentence the same comfortable mid-length, opening
  with the subject. Also its cousin, four-plus staccato declaratives in a
  row, and "No X. No Y. Just Z."
- Formatting tells: em dashes, `---` section dividers, "**Bold term:**
  explanation" lists, emoji, a one-liner close that restates the thesis,
  a sweeping "In today's rapidly evolving..." opener.
- Even, mechanical transitions: "Furthermore," "Additionally," "Moreover,"
  "That said" stitching every paragraph.

## Step 4: Rewrite each hit

Work through the marked hits. For each one:

- **Say the thing directly.** Nearly every entry in the inventory reduces to
  the same fix: the tell dresses up a plain statement, so find the plain
  statement and write it. "The tension lives in the gap between X and Y"
  means "X and Y conflict." Write that.
- **Cut rather than swap when the tell is pure filler.** "It's worth noting
  that the deploy finished" is "The deploy finished." Value-claims,
  throat-clearing, and signposting usually delete cleanly.
- **Don't trade one tic for another.** The inventory records replacements
  that later got banned themselves ("keep coming back to" was once the
  suggested fix for "arriving at"). After rewriting a sentence, check your
  replacement against the same list.
- **Vary the rhythm on purpose.** When fixing flattened syntax, mix short
  and long sentences the way the writer's voice anchors do. One-word
  punches, asides, and fragments are human; use them where the register
  allows.
- **Leave the writer's own quirks alone.** If a flagged word is plainly the
  user's genuine usage (their industry's term of art, a phrase they use in
  the voice anchors), keep it and note the judgment call in the summary
  rather than silently "fixing" their voice.

## Step 5: Re-sweep your own output

Rewrites introduce tells. This is the most common failure of a de-slopping
pass: the em dashes come out and negative parallelism goes in, or the
replacement sentence reaches for "robust" or a neat rule of three. Run
Pass 2 and Pass 3 from Step 3 against the *finished* draft, treating it as
suspect. Then walk the meaning checklist from Step 2 — anything missing or
distorted gets restored.

## Step 6: Deliver

Lead with the cleaned draft itself, in a block that copies cleanly into
wherever it's going. Below it, keep commentary short:

- A compact summary of what was stripped, grouped by family ("removed 6 em
  dashes, 2 negative parallelisms, 3 'worth X' value-claims...") — enough
  for the user to trust the pass without rereading everything.
- Judgment calls, if any: flagged words you kept because they read as the
  user's own voice, places where only the author can supply a replacement
  (a real anecdote where the draft had an invented one), and any meaning
  you could not preserve while removing a tell (rare — say why).

Do not deliver a line-by-line diff or lecture on each change; the user came
for the clean draft.

## Fallback checklist (when the fetch fails)

The highest-signal families from the inventory, compressed. This is a floor,
not the full list — say in your delivery that the live inventory was
unavailable and this pass used the built-in subset.

- **Em dashes** — the most reliable single tell. Replace with commas,
  periods, parentheses, or spaced hyphens per the surrounding voice.
- **Negative parallelism** — "not just X, it's Y" and all cleft contrasts.
- **AI vocabulary** — delve, tapestry, testament, underscore, leverage,
  robust, seamless, holistic, intricate, comprehensive, navigate
  (figurative), landscape, realm, foster, harness, pivotal, transformative,
  game-changing, groundbreaking, unpack, surface (as verb), double-click,
  pressure-test, north star, paradigm shift, at the end of the day.
- **Value-claim filler** — "worth [anything]," "it's worth noting," "this
  matters," "the right [X]," "the useful thing."
- **Totalizers and crowned superlatives** — "the whole [X]," "the only [X]
  that [verb]," "the most/best [X]," "that's the whole game."
- **Pseudo-reflective framing** — "sit with," "keep coming back to," "where
  I landed," "I can't stop thinking about," "what struck me most."
- **"Real" and writerly modifiers** — the adjective "real" ("the real
  value," "real reviews"), metaphorical "quieter"/"louder," "quietly" as
  hidden-drama adverb.
- **Placement/agency metaphors** — abstractions that live, hold, carry,
  compound, or do work; "the engine," "the shape of," "load-bearing."
- **Invented observation/emotion** — "most people I've talked to," "hit a
  nerve," "stuck with me" — unless the experience is real and stated.
- **Signposting and throat-clearing** — announcing structure, "Here's where
  it gets interesting," "Let's break it down," restating the question,
  sweeping "In today's..." openers, one-liner thesis closes.
- **Rule of three and flattened rhythm** — forced triples; uniform
  mid-length subject-first sentences; 4+ staccato declaratives; "No X. No
  Y. Just Z."
- **Formatting** — `---` dividers, "**Bold term:** explanation" lists,
  emoji, mechanical bold.
- **Sycophancy and hedging** — "Great question," "I'd be happy to," "It's
  important to note," "That said" as a universal joint.

## What not to do

- **Don't change the answer, facts, or claims.** A clean draft that says
  something different is a failure, not a success.
- **Don't sand the voice flat.** Uniform beige prose is a tell too. If the
  original had bite, the output has bite.
- **Don't invent to fill gaps.** Where the draft fabricated experience
  ("most people I've talked to..."), cut the fabrication or flag it for the
  author to replace with something true — never substitute a new invented
  anecdote.
- **Don't impose the inventory's house style.** Strip tells; pick
  replacements in the user's voice.
- **Don't shorten for its own sake.** Filler leaves, content stays. If the
  draft comes back dramatically shorter, you cut meaning.
- **Don't skip the re-sweep.** Your rewrites are drafts too, and they get
  the same scrutiny.
