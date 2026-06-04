# REVIEW.md guidance

## What REVIEW.md is for

REVIEW.md is **reviewer-facing** guidance — context for someone (or some agent)
reviewing a change, used by `/code-review`, `/security-review`, and `/review`. It
answers: *when reviewing this codebase, what deserves extra scrutiny, what must
stay true, and what looks alarming but is fine?*

This is a different moment from authoring. CLAUDE.md guides Claude while it
*writes* code; REVIEW.md guides whoever *reviews* it. Keeping them separate is the
whole point of this file (see "The no-overlap rule" below).

### How the review commands actually consume guidance

Worth knowing, so expectations are honest: the official `/code-review` command
reads the repo's **CLAUDE.md** files for guideline-compliance checks — it does not
automatically discover a REVIEW.md. REVIEW.md is therefore most useful as a
purpose-built guidance document a reviewer or review command is **pointed at**, and
as the natural companion to a security review. Write it as the place that holds
review priorities the team has agreed on, independent of whether a given command
auto-loads it. Don't claim in the file that any command reads it automatically.

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

REVIEW.md must not duplicate CLAUDE.md. They are read at different times for
different purposes, and overlap is the main way REVIEW.md goes wrong — it drifts
into restating coding conventions, then the two files disagree as one is updated
and the other isn't.

A simple test for which file a line belongs in:

- **"How should I write this?"** → CLAUDE.md (conventions, commands, architecture,
  authoring gotchas).
- **"What should I scrutinize in someone's change, and what must not break?"** →
  REVIEW.md (risk areas, invariants, false positives).

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
