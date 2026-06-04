---
name: sync-repo-docs
description: Create or audit a repo's three core doc files — README.md, CLAUDE.md, and REVIEW.md — in that dependency order. If a file is missing, generate it from the actual codebase; if it exists, audit it against the current code and apply targeted fixes after confirmation. README.md gets a developer from clone to a running debug build; CLAUDE.md captures coding guidance for Claude (delegating to /init or the claude-md-improver skill); REVIEW.md holds reviewer-facing guidance for automated code review agents without duplicating CLAUDE.md. Target files with --readme, --claude, and --review, or run all three by default. Use whenever the user wants to set up, bootstrap, scaffold, refresh, audit, update, or sync a repo's docs, or says things like "create a README", "is my README still accurate", "write a CLAUDE.md", "audit our docs", or "get this repo ready for contributors" — even if they name only one of the three files. Prefer it over claude-md-improver alone when README or REVIEW are also in scope.
---

# sync-repo-docs

Create or audit the three documentation files that orient a developer (and Claude) to a repository:

- **README.md** — for humans. Gets a developer from a fresh clone to a running debug build.
- **CLAUDE.md** — for Claude. Coding guidance and project context used while *writing* code.
- **REVIEW.md** — for reviewers. Guidance used while *reviewing* code, by humans or automated code review agents.

For each file: if it's missing, create it from the actual codebase; if it exists, audit it for accuracy and propose targeted fixes. Creating a file is a normal write; changing an existing file is gated behind a confirmation checkpoint, because the user may have written something deliberately that looks wrong from the outside.

## Why this order

Always process the files in this sequence — **README.md → CLAUDE.md → REVIEW.md** — because each settles facts the next one reuses:

1. **README.md first** establishes the canonical one-line purpose, the build/test commands, and the architecture-in-brief — verified against the repo.
2. **CLAUDE.md** can then reuse those verified commands and that structure instead of rediscovering them, and must not contradict the README.
3. **REVIEW.md last** must avoid duplicating CLAUDE.md (see Step 3), so CLAUDE.md has to be settled before REVIEW.md is written.

Finish one file — including its confirmation checkpoint — before starting the next. That way later files build on the *approved* version of earlier ones, not a draft.

## Selecting targets

Flags choose which files to process:

- `--readme` → README.md only
- `--claude` → CLAUDE.md only
- `--review` → REVIEW.md only

Flags combine (`--readme --review` does both). **With no flags, process all three.** Whatever the subset, always run it in the canonical order above — flag order on the command line is irrelevant.

## The shared rhythm for every file

Each step below is one of two paths, decided by whether the file already exists at the repo root:

**Create path (file absent):**
1. Gather what the file needs by reading the repo (not by guessing).
2. Write the file.
3. Show the user what you created and why it's shaped that way.

**Audit path (file present):**
1. Read the existing file.
2. Cross-reference every concrete claim against the current codebase — commands, paths, versions, prerequisites, architecture. A doc is wrong the moment the code moves underneath it; staleness is the default failure mode, so verify rather than trust.
3. Produce a findings report: what's accurate, what's stale/broken/missing, and the specific fix for each problem.
4. **Stop and ask** for confirmation before editing. The user may have written something intentionally that looks off, or may want to fix it themselves.
5. On approval, apply targeted edits with `Edit` — change only what's inaccurate.

Read the relevant reference file before doing a README or REVIEW step; they hold the structure and the audit lens for each.

## Step 1 — README.md

Read [references/readme-guidance.md](references/readme-guidance.md) first. The README's job is **orientation** — a newcomer should come away understanding what the project is and how to get it running (a debug build for an app; install-and-use for a library or tool). Judge it by whether the information needed for orientation is present, accurate, and findable — *not* by whether it follows a particular structure. The guidance file holds the orientation checklist and how create and audit differ.

**Create:** Inspect the repo to learn what a newcomer actually needs — language/runtime and version, package manager, build/test/run commands (from `package.json`, `*.csproj`/build scripts, `Makefile`, `pyproject.toml`, etc.), required tooling, environment/config, and whether any deeper docs exist to link. Then write a README that covers the orientation checklist, arranged however suits the repo, including only the items that apply (don't invent a docs or configuration section the repo has no use for).

**Audit:** Verify the existing README against the repo — do the documented prerequisites, setup steps, and commands still work and match reality, and do referenced docs/paths still exist? Surface anything stale, broken, or misleading that would leave a newcomer stuck. A missing optional section is not automatically a defect — judge gaps by whether they actually impair orientation. **Do not restructure or reformat an existing README** — match its existing structure and only fix accuracy. Larger formatting changes are out of scope unless the user asks.

## Step 2 — CLAUDE.md

CLAUDE.md is Claude's working context: build/test commands, architecture, conventions, and non-obvious gotchas — concise, project-specific, every line earning its place. Reuse the facts settled in Step 1 (purpose, commands, structure) rather than rediscovering them.

**Create (file absent):** Do what `/init` does — analyze the codebase and write a fresh CLAUDE.md. If the **claude-md-improver** skill (from the `claude-md-management` plugin) is installed, you may hand off to it after creation to refine the result. Keep it concise and actionable: commands that copy-paste cleanly, real paths, a brief architecture map, and the gotchas a new session would otherwise stumble on. Skip generic best-practice advice — it isn't project-specific and wastes the context window.

**Audit (file present):** Do what the **claude-md-improver** skill does. If that skill is installed, invoke it. If it isn't, follow its workflow inline: score the file (commands, architecture clarity, non-obvious patterns, conciseness, currency, actionability), output a quality report, stop for confirmation, then apply targeted additions/fixes — flagging stale commands, deleted-file references, outdated tech versions, and undocumented gotchas. Don't pad the file with obvious or generic content.

Either way, this step keeps the skill's standard rhythm: for an existing file, report → confirm → apply.

## Step 3 — REVIEW.md

Read [references/review-guidance.md](references/review-guidance.md) first. REVIEW.md is reviewer-facing guidance for whoever reviews a change — a human or an automated code review agent: what to scrutinize in this codebase, security-sensitive surfaces, invariants that must hold, and known false-positive patterns reviewers should not flag.

The defining constraint: **REVIEW.md must not duplicate CLAUDE.md.** They serve different moments — CLAUDE.md guides writing code, REVIEW.md guides reviewing it. Before writing or accepting any REVIEW.md content, check it against the CLAUDE.md settled in Step 2 and drop anything already covered there. The guidance file explains how to keep the two cleanly separated.

**Create:** Derive review priorities from the codebase — trust boundaries, auth/crypto/input-handling code, concurrency, money/units math, and other places where a subtle change does real damage — and write REVIEW.md per the recommended structure.

**Audit:** Verify the existing REVIEW.md still matches the code (do the referenced risk areas and files still exist?) and, critically, check for overlap that has crept in against the current CLAUDE.md. Report → confirm → apply.

## Things not to do

- **Don't** edit an existing file without showing findings and getting confirmation first. Creating a missing file is fine to do directly; rewriting something the user wrote is not.
- **Don't** restructure or reformat an existing README. Audit for accuracy and match the structure that's there.
- **Don't** process the files out of order. README → CLAUDE → REVIEW exists so each builds on the approved version of the last.
- **Don't** let REVIEW.md and CLAUDE.md say the same things. Overlap is the main way REVIEW.md goes wrong — when in doubt, leave authoring guidance in CLAUDE.md and keep REVIEW.md about what to scrutinize.
- **Don't** invent commands, prerequisites, or architecture. Every concrete claim in any of these files must be verified against the repo — an unverified doc is worse than no doc.
- **Don't** pad CLAUDE.md or REVIEW.md with generic best practices. Project-specific, non-obvious content only.
