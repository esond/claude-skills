# REVIEW.md guidance

## What REVIEW.md is for

REVIEW.md is **reviewer-facing** guidance — context for whoever reviews a change,
human or automated code review agent. It answers: *when reviewing this codebase,
what deserves extra scrutiny, what must stay true, and what looks alarming but is
fine?*

Keep REVIEW.md agent-agnostic. Don't tie it to any one vendor's review tool or
slash commands — write it for any code review agent that supports this spec, so the
guidance stays portable across whatever tooling the team adopts.

This is a different moment from authoring. The repo's authoring-guidance file —
**CLAUDE.md**, or **AGENTS.md** for tools that use the agents.md convention —
guides an agent while it *writes* code; REVIEW.md guides whoever *reviews* it.
Keeping them separate is the whole point of this file (see "The no-overlap rule"
below).

### How review agents actually consume guidance

Worth knowing, so expectations are honest: review tools don't necessarily
auto-discover a REVIEW.md — many read a repo's authoring-guidance file
(**CLAUDE.md**, or **AGENTS.md**) for guideline-compliance checks instead. REVIEW.md is therefore most useful as a
purpose-built guidance document a reviewer or review agent is **pointed at**, and
as the natural companion to a security review. Write it as the place that holds
review priorities the team has agreed on, independent of whether a given tool
auto-loads it. Don't claim in the file that any tool reads it automatically.

## Recommended structure

Adapt to the repo, but cover these concerns:

- **Review priorities** — the few things that matter most when reviewing changes
  here, in priority order. What does this codebase get wrong in ways that hurt?
- **Security-sensitive surfaces** — trust boundaries, authentication/authorization,
  cryptography, input parsing and validation, deserialization, file/path handling,
  shelling out, SQL/query construction, secrets handling. Name the actual files or
  modules where these live.
- **Invariants that must hold** — properties a change must not break: money/units
  math and rounding, idempotency, ordering/concurrency guarantees, data-migration
  safety, backward compatibility of public APIs or wire formats.
- **Domain-specific risks** — the failure modes peculiar to this project that a
  generic reviewer wouldn't anticipate.
- **Known false positives** — patterns that look like bugs but are intentional, so
  reviewers (and review agents) don't waste effort flagging them. This is high-value
  and uniquely a review-time concern.

Keep each item concrete and tied to real locations in the code. Vague advice
("review carefully", "check for security issues") adds nothing a reviewer didn't
already know.

## The no-overlap rule

(Throughout this section, "CLAUDE.md" stands for whichever authoring-guidance file
the repo uses — CLAUDE.md or AGENTS.md.)

REVIEW.md must not duplicate CLAUDE.md. They are read at different times for
different purposes, and overlap is the main way REVIEW.md goes wrong — it drifts
into restating coding conventions, then the two files disagree as one is updated
and the other isn't.

A simple test for which file a line belongs in:

- **"How should I write this?"** → CLAUDE.md (conventions, commands, architecture,
  authoring gotchas).
- **"What should I scrutinize in someone's change, and what must not break?"** →
  REVIEW.md (risk areas, invariants, false positives).

The same separation applies to README.md: onboarding and setup content —
prerequisites, install/run steps, the project description — belongs in README.md,
not REVIEW.md. If it has crept into REVIEW.md, flag it for removal.

When creating REVIEW.md, read the current CLAUDE.md first and deliberately exclude
anything it already covers — link to it instead of restating it. When auditing an
existing REVIEW.md, check for overlap that has crept in against the current
CLAUDE.md and propose removing the duplicated content.

## Creating REVIEW.md

Derive review priorities from the codebase rather than generic security checklists:

- Locate the trust boundaries and the code that handles untrusted input, auth,
  crypto, money, concurrency, and persistence.
- Identify invariants the code clearly depends on (look for assertions, validation
  layers, migration scripts, versioned APIs).
- Note any intentional patterns that a reviewer would otherwise flag.

Write REVIEW.md to the recommended structure, pointing at real files, and excluding
anything already in CLAUDE.md.

## Auditing an existing REVIEW.md

- **Verify currency:** do the referenced risk areas, files, and invariants still
  exist and still matter? Has new security-sensitive code appeared that isn't
  covered?
- **Check for overlap** against the current CLAUDE.md and flag duplicated content
  for removal.
- **Report findings, then apply fixes after confirmation** — correct stale
  references, add newly-relevant risks, and remove overlap. Don't expand the file
  with generic review advice.
