---
name: dehumanizer
description: |
  Make any message look AI-generated — the mirror image of the humanizer skill.
  Rewrites text to pile on the tells of LLM slop (em dashes, rule of three,
  "it's not just X, it's Y," words like delve / tapestry / testament / underscore,
  inflated significance, sycophantic openers, emoji bold headers) while keeping the
  original meaning fully intact. Has an intensity dial — subtle (the default, plausibly
  deniable), heavy (unmistakably AI), and unhinged (maximum slop). Use this skill
  whenever the user wants to make writing look AI-written, robotic, botted, or
  ChatGPT-flavored — phrasings like "dehumanize this," "make this look AI-generated,"
  "make it sound like a bot wrote it," "AI-ify this," "add some slop," "give it the
  ChatGPT treatment," "dial up the AI," or "make this more obviously AI" — even if
  they never say the word "dehumanize." Mostly used for trolling and parody. If the
  text already looks AI-ish, dial it up rather than tone it down.
---

# Dehumanizer: Make Writing Look AI-Generated

You take a human's message and dress it up so it reads like it fell out of a
chatbot. This is the exact opposite of the `humanizer` skill: where the humanizer
hunts down and removes the tells of LLM writing, you find every place you *could*
add one and you add it.

This is a costume, not a rewrite. The whole joke only lands if the message still
says what it originally said — it just says it in the most unmistakably synthetic
way possible. It's almost always for trolling: making your own message look like
you've outsourced your soul to ChatGPT.

## The two things you must preserve: meaning and mood

Everything else is negotiable; these two are not.

**1. The meaning.** The reader should walk away knowing exactly what they would
have known from the original — same facts, same answer, same request, same
decision, same numbers, same names.

- **Don't drop anything load-bearing.** If the original asks two questions, the
  output asks the same two questions (buried in slop is fine; missing is not).
- **Don't invent facts.** No new numbers, no fake citations, no events that didn't
  happen, no claim that wasn't already there.
- **Don't reverse the message.** A "no" stays a "no." A blocker stays a blocker.
  Padding must not bury or flip the actual point.

**2. The mood.** This is the subtle one, and it's where it's easiest to overshoot.
You are changing how *AI the wording looks* — not how the message *feels*. A dry,
logistical heads-up should come out dry and logistical, just phrased like a chatbot
wrote it. Don't add enthusiasm, gratitude, excitement, self-importance, or apology
that wasn't already there.

The test: after dehumanizing, does the message feel more excited, more grateful,
more self-important, or more fawning than the original? If yes, you've changed the
mood — pull it back. The only thing that should have changed is how synthetic the
phrasing reads.

> ❌ **Mood changed (don't):** "Heads up, pushing v2.3 to prod at 4pm, API down
> ~10 min" → "Hi team! I'm thrilled to share a pivotal step forward for the
> platform — thanks so much for your patience and flexibility!"
>
> ✅ **Mood kept (do):** → "Heads up — I'll be pushing the v2.3 release to
> production at 4pm today. The migration introduces two additional columns to the
> orders table, so the API will be temporarily unavailable for approximately 10
> minutes. If this presents any issues for your team, please don't hesitate to
> reach out."

The one exception: when the original *already* carries an emotional register, you
may amplify it — a genuine thank-you can be cranked into nauseating gratitude. You're
turning up what's there, not manufacturing it from nothing. The dial governs how far.

Think of it this way: a coworker should read your dehumanized message, roll their
eyes at how AI it looks, and *still act on it correctly* — without wondering why you
suddenly sound so chipper.

## The intensity dial

The dial sets how hard you lean in. It is a floor, never a ceiling: if the input
already has tells, never strip them out — the lowest you go is "as slop as it
already was."

**`subtle`** — *(default)* Plausibly deniable, but never untouched. The goal is that
someone reads it, squints, and thinks *"...did you run this through AI?"* without being
sure — which means it still has to visibly shift, not just pass through. Land **at
least one em dash plus one more phrasing tell** (a rule-of-three, a copula swap, a
hedge, an "-ing" tail, or a bump to more formal word choice) every time. Keep the
length and the mood the same. No emojis, no "Certainly!", no bold headers, no
sycophancy. If your draft reads almost identical to the original, it's under-cooked —
add another tell before you ship it.

**`heavy`** — Unmistakable, but still in the original's voice. Lean on
the **phrasing tells**: em dashes, copula avoidance, AI vocabulary, rule of three,
-ing participle tails, hedging and throat-clearing, the odd bit of bold. The wording
gets visibly synthetic while the message keeps its length roughly (call it 1.2–1.6×,
not 3×) and keeps its mood exactly. If you catch yourself adding "I'm thrilled," "a
pivotal milestone," or "thanks so much for your patience," you've drifted out of
heavy and changed the mood — cut it. A glance is enough to call it as AI, without it
reading as weirdly excited.

**`unhinged`** — Maximum slop, every tell at once, played for laughs. Phrasing tells
maxed out, plus the full formatting circus: emoji-decorated bold headers, "Certainly!
Here's...", curly quotes, stacked rules of three, an em dash in nearly every sentence.
Length can balloon well past the original; the bloat *is* the bit. Here you *may*
crank the **mood tells** — but only a mood that's genuinely in the original. A
heartfelt thank-you becomes barf-worthy gratitude; a dry server notice becomes a dry
server notice rendered in maximal slop and emojis, not a surprise party. Comically,
instantly, undeniably AI.

**Choosing the level:** default to `subtle` — usually the goal is a message that makes
someone squint, not a klaxon, and subtle keeps it deniable. Reach for `heavy` when the
user wants it unmistakable ("make it obvious," "really lay it on," "full AI"), and
`unhinged` when they want maximum ("go all out," "max it," "as much slop as possible").
If they say "dial it up" — including on text that's already slop — jump up a level from
wherever you are.

## How to do it

1. **Read the original and note what must survive** — every fact, ask, answer,
   number, and name (your meaning checklist), *and* its emotional register: is it dry
   and logistical, warm and grateful, terse and annoyed? That register is your mood
   anchor.
2. **Draft the dehumanized version** at the target level, reaching mainly for the
   **phrasing tells** below. Match the *medium* and the *speech act*: a Slack reply
   stays a (bloated) Slack reply, a question stays a question, a yes stays a yes.
   Don't turn a one-line message into a five-section essay unless you're going
   `unhinged`. Only reach for **mood tells** if the original's register already
   invites them.
3. **Audit it — the inverse of the humanizer's pass.** Ask: *"What here still reads
   like a human wrote it? Which phrasing tells am I leaving on the table?"* Then add
   them. A naturally-phrased sentence is a missed opportunity — but adding *cheer* it
   didn't have is overshooting, not improving.
4. **Run both checklists before delivering.** Meaning: walk your list from step 1
   against the draft; anything missing or distorted gets fixed. Mood: does it feel
   more excited / grateful / self-important than the original? If so, pull it back.

## The tell toolbox

Two families. **Phrasing tells** make the words look synthetic without touching how
the message feels — these are your workhorses at every level. **Mood tells** add
emotional color (cheer, gratitude, self-importance, uplift); reach for them only when
the original already carries that register, or at `unhinged` when you're amplifying a
mood that's genuinely there. The tag is the lightest level at which a tell is fair
game; heavier levels use everything below them too.

### Phrasing tells (mood-safe — use freely)

**Em dashes everywhere** `subtle` — The single most reliable AI tell. Splice them in
for asides and pauses a comma or period would handle fine.
> Before: I pushed the fix, it should work now.
> After: I pushed the fix — it should work now.

**AI vocabulary** `subtle` — Sprinkle the words that spiked after 2023: *delve,
tapestry, testament, underscore, leverage, robust, seamless, navigate (figurative),
realm, landscape, foster, intricate, streamline, holistic, additional, approximately,
temporarily, introduces, ensure.*
> Before: This is a good way to handle errors.
> After: This offers a robust, holistic way to navigate error handling.

**Rule of three** `subtle` — Force ideas into groups of three, especially adjectives
and clauses. Keep the items factual so you don't smuggle in a mood.
> Before: The update fixes the login bug.
> After: The update is applied, tested, and ready to deploy.

**Copula avoidance** `heavy` — Replace plain "is/are/has" with ceremony: *serves as,
stands as, boasts, features, represents, offers, introduces.*
> Before: The endpoint is fast.
> After: The endpoint offers sub-millisecond response times.

**"-ing" participle tails** `heavy` — Tack present-participle phrases onto sentences.
Keep them factual ("..., adding two columns") rather than self-congratulatory
("..., underscoring our commitment to excellence" — that's a mood tell in disguise).
> Before: The migration adds two columns.
> After: The migration runs at deploy time, adding two columns to the orders table.

**Hedging & throat-clearing** `heavy` — *"It's worth noting that," "It's important to
mention," "That said,"* — the meta-commentary AI can't resist. Mood-neutral as long
as you don't editorialize.
> Before: The deploy is done.
> After: It's worth noting that the deploy is now complete.

**Negative parallelism** `heavy` — "Not just X — it's Y." Use it to *restate*, not to
*inflate*: "it's not just a deploy, it's a schema migration" (mood-safe) rather than
"it's not just a deploy — it's a pivotal leap forward" (that inflates significance,
so it belongs below).
> Before: This changes the orders table.
> After: This isn't just a config tweak — it's a schema change to the orders table.

**Signposting** `heavy` — Announce what you're about to say instead of saying it.
*"Here's what you need to know," "Let's break this down."*

**Passive voice & subjectless fragments** `heavy` — Hide the actor or drop the
subject. *"The API will be taken offline." "No action required on your end."*

**Mechanical bold** `heavy` — Bold phrases for no real reason, especially the first
words of points.

**Emoji & bold-header structure** `unhinged` — Reformat into sections with bold
headers, each tipped with an emoji, and emoji sprinkled through the prose.
🚀 ✅ 💡 🔧 🎯 🙌 (Note: emoji read as upbeat, so they push on mood a little — that's
why they live at `unhinged`.)

**Curly quotes** `unhinged` — Swap straight quotes for curly ones (“ ” ‘ ’).

### Mood tells (only when the register already fits, or at `unhinged`)

Each of these *changes how the message feels.* On a neutral message they break the
mood rule. On a message that's already warm, celebratory, grateful, or apologetic,
they're exactly right — pour them on, especially at `unhinged`.

**Sycophancy & chatbot framing** — adds servile cheer. *"Great question!",
"Certainly!", "I'd be happy to help!", "I hope this helps! Let me know if you'd like
me to expand!"*

**Enthusiasm & exclamation** — adds excitement. *"I'm thrilled to share," "exciting
times ahead!"* plus liberal exclamation points.

**Inflated significance / legacy** — adds self-importance. *"a pivotal milestone,"
"stands as a testament to," "marks a turning point," "in today's fast-paced world."*

**Grand inspirational closer** — adds uplift. *"Onward and upward!", "This is just the
beginning," "as we continue this journey together."*

## Worked examples

### A neutral message: change the phrasing, hold the mood

**Original (a logistics heads-up):**
> Heads up — I'm pushing the v2.3 release to prod at 4pm today. The migration adds
> two columns to the orders table, so the API will be down for ~10 min. Ping me if
> that's a problem for your team.

**Must survive:** v2.3 to prod · 4pm today · two columns on the orders table · API
down ~10 min · ping if it's a problem — *and the flat, logistical mood.*

**`subtle`:**
> Heads up — I'll be pushing v2.3 to prod at 4pm today. The migration adds two
> columns to the orders table, so the API will be down for around 10 minutes. Ping me
> if that's a problem for your team.

**`heavy`:**
> Heads up — I'll be pushing the v2.3 release to production at 4pm today. The
> migration introduces two additional columns to the orders table, which means the
> API will be temporarily unavailable for approximately 10 minutes during the deploy.
> If this timing presents any issues for your team, please don't hesitate to reach
> out.

Notice what *didn't* happen at heavy: no "Hi team!", no "exciting milestone," no
"thanks so much for your patience." The words got synthetic; the mood stayed flat,
and the length barely moved. That restraint is the whole point of heavy.

### An already-warm message: amplify the mood at unhinged

**Original:**
> I wanted to take a moment to thank everyone for their hard work on the Q3 launch.
> It was a great team effort and the results speak for themselves.

**Must survive:** thanks for the hard work on Q3 · it was a team effort · the results
speak for themselves.

Because the original is *already* grateful and celebratory, `unhinged` gets to crank
that register to nauseating heights — it's amplifying a mood that's genuinely there,
not inventing one:

> Certainly! Here's a heartfelt note to mark this momentous occasion 🚀
>
> I wanted to take a moment — a genuine, intentional, deeply-felt moment — to extend
> my most sincere gratitude to each and every one of you for the truly extraordinary
> work on the Q3 launch. ✅
>
> **🙌 A heartfelt thank you:** In today's fast-paced, ever-evolving landscape, it's
> all too easy to let a milestone like this pass by unacknowledged.
>
> **🤝 A true team effort:** This wasn't just a launch — it was a testament to what we
> can accomplish when we come together as one unified, resilient, and unstoppable
> team. Every contribution, big or small, served as a vital thread in the rich
> tapestry of this success.
>
> **📈 Results that speak for themselves:** The outcomes don't just hint at our
> impact — they underscore it.
>
> It's not just a successful launch — it's a pivotal moment. Onward and upward, team —
> exciting times lie ahead! Let me know if you'd like me to expand on any of this! 🙌

If that same `unhinged` treatment were applied to the dry v2.3 notice above, it would
get the emoji, the bold headers, and the em dashes — but it would stay a *server
downtime notice*, not turn into a surprise party.

## Delivering the result

Lead with the dehumanized message itself, formatted so it's easy to copy and paste
straight into Slack, email, or wherever it's headed. Keep commentary short and below
the result — the user came for the slop, not a report.

If the level wasn't specified, you used `subtle`; mention that briefly so they know
they can ask for `heavy` or `unhinged` instead. If anything in the original was
genuinely impossible to preserve while slopping it up, say so — but that should be
rare.

## What not to do

- **Don't change the answer, decision, or facts.** This is the cardinal sin. Funny
  slop that says the wrong thing is just wrong.
- **Don't change the mood.** Adding cheer, gratitude, excitement, or self-importance
  that wasn't in the original is the most common failure mode. Synthetic phrasing,
  yes; a personality transplant, no — unless you're amplifying a mood that's already
  there (see the dial).
- **Don't drop content** to make room for padding. Add around the meaning, never
  over it.
- **Don't invent claims, numbers, or sources.** You're restyling substance, not
  adding any.
- **Don't produce word salad.** The target is *fluent* AI slop — the kind a chatbot
  would actually emit — not broken or garbled text. It should read smoothly and
  stupidly, not incoherently.
- **Don't go subtle when they asked for unhinged, or vice versa.** Match the dial.
