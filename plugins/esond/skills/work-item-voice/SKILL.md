---
name: work-item-voice
description: >-
  Write the user's issues in their own voice for any work tracker — Jira,
  Linear, GitHub Issues, Azure DevOps, Shortcut. Covers the three kinds:
  features (new behavior), tasks (work that needs doing), and bugs (behavior
  that does not match expectation). Load this whenever the deliverable is an
  issue body, whether they say "file a bug", "write a ticket", "draft a story",
  "create an issue for this", "turn this into a Jira", "make a card for", "write
  this up in Linear", or paste a thread and ask for an issue out of it. Load it
  too when tightening or rewriting an issue that already exists, and when filing
  one is a step inside a larger task. Features get behavior-driven framing with
  no implementation prescribed, bugs get expected versus actual, and every type
  stays short — the writer pays the compression cost, not the reader. Not for
  replying to or commenting on an existing issue, which is a conversation turn.
---

# Work item voice

An issue is a request for work, written by one person and read by many. Every
reader pays for what the writer did not bother to cut, and every reader loses
options the writer closed off by guessing at the solution. Those two costs are
what this skill exists to keep down.

Before you draft, read `../../references/writing-for-people.md` — that is
`references/writing-for-people.md` at the `esond` plugin root. It holds the
rules this skill shares with `conversational-voice`. What follows here is what
is specific to an issue.

If that read fails, draft anyway and say so in one line. The rules below still
apply, but the shared ones are missing, and the user needs to know that before
they file the issue.

## When this applies

It applies when you are authoring the body of a work item: a feature, a task, or
a bug, in whatever tracker the team uses. It applies the same way when you are
rewriting or tightening an issue that already exists.

It does not apply to a *comment* on an issue. That is a turn in a conversation
with a person, so it belongs to the sibling skill `conversational-voice`. The
split is authored artifact versus conversational turn, not tool.

## The three kinds

**Feature** — something new the product needs. The issue describes desired
behavior and the outcome that behavior produces.

**Bug** — behavior does not match expectation. Something works differently than
it is supposed to.

**Task** — work that needs doing rather than designing: maintenance, an upgrade,
a migration, a cleanup. Tasks are allowed to be more technical, because the
question is usually *do this*, not *figure out what to do*.

Most of what follows applies to all three. Where a kind differs, it says so.

## Do not prescribe the implementation

This is the constraint that holds everywhere, including bugs.

The developer who picks up the issue knows things the author does not. They know
what landed last week, which abstraction is already half-built, and which of the
three obvious fixes has bitten them before. An issue that names the solution
throws all of that away, and it does so silently — nobody argues with a spec.

So point, do not dictate. "The retry count resets somewhere in
`OrderDispatcher`" hands over a real lead. "Move the retry count into Redis"
hands over a decision that was not yours to make.

The common way this goes wrong now: someone points an LLM at the codebase, asks
why a bug happened, and files the answer. What lands in the tracker is a
diagnosis wearing an issue's clothes. The reported behavior is a sentence at the
top, and the rest is a proposed fix nobody asked for. If you have a hypothesis,
it goes at the bottom, marked as a hypothesis, or it stays out.

An issue can still carry an implementation detail when the detail is genuinely a
constraint: a deadline set by a vendor API, a table that cannot change, a
decision already made and recorded elsewhere. Say it as a constraint and say who
set it. That is different from designing the fix.

## Features: describe the behavior, not the machinery

Write the problem statement so it would make sense in 1922. Almost all software
does something a person could already do by hand, just slower and less
reliably — so describe that thing. A clerk, a ledger, a phone call, a filing
cabinet. If the sentence cannot survive the removal of computers, it is probably
describing machinery instead of behavior.

That framing is what makes room for concrete detail. Behavior-driven writing
wants the specifics of the problem domain: real names, real dates, real amounts,
a real example of the case that fails. "A customer on the annual plan cancels on
day 40 and expects a prorated refund" is worth more than three paragraphs about
subscription state.

The user story shape — as a *someone*, when *something*, so that *outcome* — is
welcome whenever it fits, and it is not required. Do not force a feature into it.
The part of that shape that usually earns its place is the persona: who wants
this, and what they get. That answers questions a shape alone does not.

What every feature must contain, in whatever form suits it:

- What is desired
- What the outcome is once it exists

Everything else is optional. Background is the optional part worth keeping.

After the spec is done — what is wanted, the outcome, whatever acceptance
criteria you wrote — an addendum on why this exists and how it came about earns
its place. Where it came from, who asked, what the team tried before, the
constraint that made it urgent. This part reads more prosaic than the rest, and
that is fine. It answers the questions a developer asks in week three rather
than on day one.

Position is what makes it free. A reader who only needs to start reads the top
and stops, so nothing is spent on them. That works only when background sits
last, under its own heading, and never gets mixed into the statement of what is
wanted. A task with real history can carry the same addendum.

## Bugs: what happened, what was expected, how to see it

Bugs get a light skeleton, because the three facts a developer needs first are
always the same and are easy to leave out:

- **What happened** — the observed behavior, stated plainly.
- **What was expected** — and where that expectation comes from, if it is not
  obvious.
- **How to see it** — steps, or the conditions under which it shows up.

Add environment, frequency, and blast radius when you know them. Add a pointer
to a suspicious bit of code when you have one, as a lead rather than a verdict.

## Tasks: the outcome and the edges

A task needs the outcome it produces and a clear enough boundary that someone
knows when it is finished. Technical vocabulary is fine here. Prescribing *how*
is still not.

## The test for what survives

The shared reference states the compression rule. Long issues are where it bites
hardest, because one person writes the issue and every reader after them pays.
The test for any sentence here: **does a developer need this fact to start?**

Keep a date, an amount, a customer name, a concrete failing example, an
expectation and where it came from, a constraint someone else set. Cut a log
excerpt nobody asked for, a list of files you happened to read, the story of
your own debugging session, and anything included to show that research was
done. Research that shaped the issue is already in the issue, in the form of a
shorter issue.

A background addendum is the one exemption, and it survives on a different test.
It fails "need this to start" by design. It passes because it sits last, under
its own heading, where a reader who is done reading has already stopped. Keep it
that way and it costs nobody anything. Move it up front and it is a context
dump.

## Language

Write for a reader whose first language is not English.

Short sentences. One idea in each. Active voice, and name who acts. Plain words
over impressive ones. State a condition before the thing it governs. No idioms,
because they are the first thing to fail across languages.

That is the flavor of ASD-STE100 and not the whole standard. Certified
compliance is not the goal. A term from the problem domain stays as it is, even
when a plainer word exists, because renaming the domain to sound simpler makes
the issue wrong.

Some of the AI tells catalogued in `conversational-voice` carry over. An issue
that opens with a summary of itself, lists exactly three considerations, or ends
on a tidy restatement reads as generated, and readers discount it.

## Formatting

The rule against mechanical structure in `conversational-voice` does not carry
over. That one is calibrated for Slack, where most messages are one paragraph.
A tracker is the opposite. People scan issues, come back to them weeks later,
and read them next to twenty others.

So headings, bold labels, and short lists earn their place here. Use them where
they help someone find one fact fast: the date, the expected behavior, the
condition that means done. Skip them when the issue is two sentences long, since
structure around nothing is its own kind of noise.

Match the shape to the content, the same way you match the length to it.

**Do not hard-wrap the body.** Every tracker soft-wraps to the reader's window.
A body wrapped at 80 columns reads badly on a phone, fights the next person who
edits it, and turns a one-word change into a reflowed paragraph. Write each
paragraph as one long line and let the tracker break it.

The examples below break this rule, and they will mislead you if you copy their
shape. They wrap at 80 columns because this file does. Take their structure and
their register. Do not take their line breaks.

## Examples

**A feature:**

> **Prorate refunds when an annual plan is cancelled mid-term**
>
> A customer on the annual plan cancels partway through the year. Today they get
> nothing back. They expect money back for the months they will not use.
>
> Priya subscribes on 1 March for $240. She cancels on 9 April, 40 days in. She
> expects about $214 back, the value of the 325 days she will not use.
>
> Once this exists, a customer who cancels early gets a refund for the unused
> part of the term, and sees the amount before they confirm the cancellation.
>
> **Background**
>
> Support has handled these by hand since we launched annual billing. It was
> fine at a handful a month. It is now about forty, and Dana raised it after two
> customers were refunded the wrong amount in June. We looked at blocking
> mid-term cancellation instead and decided against it, because renewals are the
> thing we actually want to protect.

Not: "Add a `prorate()` helper to `SubscriptionService` that computes remaining
days over 365 and calls the Stripe refund endpoint. We should cache the plan
price on the subscription row so we don't hit the price table on every
cancellation."

**A bug:**

> **Orders placed during a deploy never reach the warehouse**
>
> **What happened.** Between 09:12 and 09:15 ET on 4 August, 23 orders were
> confirmed to the customer and never appeared in the warehouse queue. The cards
> were charged.
>
> **What was expected.** Every confirmed order reaches the warehouse. Support
> tells customers that a confirmation means the order is committed.
>
> **How to see it.** Place an order while a deploy is in progress. It happened
> on all three attempts on staging.
>
> One lead, not a diagnosis: the dispatcher's retry buffer is in memory, so a
> restart is worth looking at.

Not: "The dispatcher loses its retry buffer on restart because it's held in a
local list. We need to move it to Redis so it survives deploys. See
`OrderDispatcher.cs:88`." Followed by forty lines of log.

**A task:**

> **Move the nightly export off the retired reporting database**
>
> The reporting database is switched off on **30 September**. The nightly
> customer export still reads from it, so the export stops working that day.
>
> **Done when**
>
> - The export runs against a supported source.
> - It produces the same columns it produces today.
> - Its output matches the current export for a week of sample dates.

Not: "Rewrite `NightlyExportJob` to take `IWarehouseClient` instead of
`IReportingDbClient`, port the SQL to the new star schema, and put it behind a
feature flag so we can roll back." A task can use technical vocabulary. It still
does not get to design the work.

Notice what the good versions share. Each one names the behavior and the gap,
carries the few facts a developer needs to start, and stops. None of them says
how to build it.

## Delivering the draft

The shared reference covers this. Two things are specific here.

Lead with a title line, then the body in a fenced block so it pastes into the
tracker cleanly. The fenced block is where the wrapping rule gets broken,
because a wall of text looks wrong in a terminal. Do not wrap it anyway. What is
inside the block is what someone pastes, and the hard breaks travel with it.

A title says what is wrong or what is wanted, in one line, without a prefix
naming the type — the tracker already carries that field.

## Filing the issue

Drafting is the default. Filing is the exception, and only on request.

When asked to file, stop and confirm before any write. Show the rendered title
and body, name the target — project, repository, board, or team — and name the
type. Wait for a yes. A filed issue notifies people and is awkward to retract,
so treat the confirmation as a real gate rather than a formality.

Only after confirmation, create it with whatever tool fits: the Jira or Linear
MCP tools, `gh issue create`, or the tracker the user names. Report back the key
or URL.

## What this does not do

- It does not triage, prioritize, estimate, or assign.
- It does not decide whether the issue is worth filing.
- It does not write the fix, or a plan for the fix, inside the issue.
