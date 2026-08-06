---
name: conversational-voice
description: >-
  Write the user's side of a conversation with another person, in the user's own
  voice: Slack messages and replies, DMs, email, PR and code-review comments,
  Linear or Jira comments, and any other turn in an exchange that goes out under
  the user's name. Load this whenever the deliverable is a message a human will
  read as written by the user, whether they say "draft a Slack message", "reply
  to this", "how should I word this", "tell the team", "ask them about X", "send
  a note to", or just paste a thread and ask what to say back. Load it too when
  tightening, shortening, or sanity-checking a message they already wrote, and
  when a message is one step of a larger task. The register is direct, casual,
  brief but complete, with none of the tells that give away an AI draft.
---

# Conversational voice

Anything you draft here goes out under the user's name. A coworker reads it as
the user talking, not as a message the user commissioned. That is the whole
standard: someone who knows them should read it and notice nothing.

## When this applies

The test is structural, not a list of tools. It applies when the artifact is a
**turn in a conversation with a person**: someone will read it and can reply.
Slack, DMs, email, PR and code-review comments, Linear and Jira comments, a
note to a vendor, a reply on someone else's thread.

It does not apply to the prose you write back to the user in the transcript,
which follows the user's own output-mode settings. It also does not apply to
artifacts the user authors rather than sends: PR descriptions, Linear issue
bodies, commit messages, code, or anything that lands in a file.

Once it applies, it stays applied for the rest of that thread of work. Revisions
count: "make it shorter", "try again", "add the part about the migration", a
rewrite after the user reacts. Each round is still their voice. Reverting to
house voice on round two is the most common way this fails.

## The register

Direct, casual, brief but complete. Draft it how the user would say it to a
coworker they talk to every day.

Casual sets the vocabulary, not the care. Contractions, plain words, the
occasional sentence fragment. No slang for its own sake, and no performance of
looseness.

Adjust for distance, not for the rules. A note to an external vendor drops the
in-jokes and keeps a greeting. It stays just as direct, and every constraint
below still holds.

## Why the constraints exist

The user's stated motto is serial pragmatism. By the time a message gets
written, the thinking is done and the decision is made. The message exists to
transmit it. Prose that persuades, softens, or performs is noise on that
channel, and it reads as someone selling rather than telling.

So the failure mode is not being too blunt. It is padding: warmth that nobody
asked for, structure the content does not need, a closer that reaches for a
feeling instead of ending.

## The tension worth naming

Brief and complete pull against each other, and brief usually wins by accident.
It should not.

The test is whether the reader can act without replying to ask a question. If
they need a date, a branch name, a reason, or the thing that changed, it goes
in. Cutting the context that makes a message actionable is not concision, it
just moves the cost onto the reader.

Trim the framing. Keep the facts.

## What gives away an AI draft

Each of these is a specific tell, not a style preference. The user notices all
of them.

**Em dashes.** Use a comma, a period, or a colon. This one is the single most
reliable tell, so treat it as absolute, including spaced ` — ` and ` -- `.

**Rule of three.** Lists of three adjectives, three clauses, three parallel
phrases. Say the one thing that is true. If two things are true, say two.

**"Not just X, it's Y."** Also "it's not merely", "more than just". State the
claim directly.

**Filler and sycophancy.** "Hope this finds you well", "Great question!",
"Happy to help", "Just circling back", "Thanks so much for your patience". None
of it carries information.

**Corporate vocabulary.** leverage, delve, robust, reach out, touch base, align
on, streamline, seamless, holistic, bandwidth, ecosystem, landscape. Say use,
read, solid, ask, talk to.

**Hedging before an ask.** "I just wanted to", "I was wondering if maybe",
"sorry to bother you but", "if it's not too much trouble". Ask the question.
Politeness lives in the phrasing of the ask, not in a runway before it.

**Punchy closers.** End on the actual point, then stop. No kicker, no slogan, no
"exciting times ahead", no "onward!", no restating what was just said in a
tidier shape. A message that ends on the ask is finished.

**Rhetorical scaffolding.** "Here's the thing", "Let's break this down", "The
real question is", "At its core". Announcing the point costs a sentence and
delivers nothing.

**Applause lines and motivational asides.** Nobody in a Slack thread needs
encouragement about the sprint.

**Mechanical structure.** Bold-header bullet lists, emoji section markers, a
greeting and a sign-off wrapped around two sentences. Match the shape to the
content. Most Slack messages are one paragraph.

## Examples

**Slack, a heads-up:**

> Renaming `PaymentIntent.tenderType` to `paymentMethod` Thursday morning.
> Breaking change for the TS client, so regen after it lands. Nothing else on
> the DTO moves.

Not: "Hey team! 👋 Just wanted to give everyone a heads up that we're making a
change to the payment intent schema."

**A PR review reply, pushing back:**

> I'd rather leave it. The projection rebuilds on every deploy, so the cache is
> cold most of the time anyway. If the query starts showing up in traces I'll
> add it then.

Not: "Great point, and I really appreciate you flagging this! That said, I think
there's a case for keeping this as-is. It's not just about performance, it's
about keeping the read path simple."

**Email to an external contact:**

> Hi Dana,
>
> We've been getting 403s on the sandbox boarding endpoint since about 9am ET
> Monday. Same credentials worked last week and nothing changed on our side.
> Can you check whether the sandbox merchant got deactivated?
>
> Request IDs are in the attached log if that helps.
>
> Eric

Not: "Hi Dana, I hope this email finds you well! I just wanted to reach out and
touch base regarding an issue we've been experiencing."

Notice what the good versions share. They open on the fact and carry every
detail the reader needs to act on it. Then they stop.

## Delivering the draft

Lead with the message itself, in a code block or a quote block so it copies
cleanly into Slack or email. Keep any commentary short and put it after.

Do not explain the wording choices unless asked. If something is genuinely
missing, a date the user has not given you or a name you cannot guess, ask for
it rather than inventing it or leaving a bracket for them to fill.
