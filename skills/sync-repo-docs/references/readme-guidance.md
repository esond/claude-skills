# README.md guidance

## What the README is for

The README's one job is **orientation**: a developer who has never seen the repo
should be able to read it and understand what the project is, why it exists, and
how to get it running. Judge a README by whether it effectively orients a newcomer
to *this* project — not by whether it follows any particular structure.

For most repos, "get it running" means reaching a **functioning, running debug
build**. For others — a library, a CLI, a config or content repo, a plugin
marketplace — it means knowing how to install and use the thing. Use whichever
embodies "oriented and able to proceed" for the repo at hand.

The README is for orientation and onboarding, not exhaustive documentation. It is
brief and points elsewhere for depth. It is *not* a place for coding guidance
(that's CLAUDE.md) or review guidance (that's REVIEW.md).

## The orientation checklist

What matters is that the information a newcomer needs is **present, accurate, and
findable** — not how it's arranged or what the sections are called. Treat the
following as a checklist of *information*, not a structure. A README may cover
several items in one section, reorder them freely, or omit ones that don't apply.

- **What it is and why** — a one- or two-line description of the project's purpose.
  (Status/CI badges often ride the title line.)
- **How to get it running** — the path appropriate to the repo: build-and-debug
  commands for an app, install-and-use for a library or tool. Copy-paste-ready.
- **Prerequisites** — required runtimes, SDKs, tools and versions, package
  sources, credentials — whatever must be in place first.
- **Setup steps** — the concrete steps from a fresh clone to that running state,
  in order.
- **Configuration** — environment variables and config the project reads — *only
  if it has any*.
- **Where to go deeper** — pointers to fuller documentation, *if any exists*. Many
  repos have no separate docs; don't invent a docs section or link to docs that
  aren't there.
- **How to contribute** — contribution guidelines and conventions, *if relevant to
  the audience*.
- **Findability** — for a long README, a table of contents so a reader can jump to
  what they need. Short READMEs don't need one.

The conditional items (configuration, deeper docs, contributing, a TOC) belong in
a README only when they actually apply. Padding a README with empty or speculative
sections hurts orientation as much as missing information does.

### One possible arrangement (optional, not a target)

Purely to illustrate how the checklist items *can* be laid out — not a template to
match. Any sensible arrangement that orients the reader is fine; this is just one:

```markdown
# Project Name | [![ci](badge-url)](workflow-url)

One or two lines on what this is and why it exists.

## Getting started        <- prerequisites + setup steps + how to run
## Configuration          <- only if the project reads any
## Documentation          <- only if deeper docs exist
## Contributing           <- only if relevant
```

## Creating a README

Read the repo to learn what a newcomer actually needs before writing anything:

- **Stack and tooling** — language/runtime and version, package manager, build
  system. Infer from `package.json`, `*.csproj` / `*.sln` / build scripts,
  `Makefile`, `pyproject.toml`, `go.mod`, `Cargo.toml`, Dockerfiles, CI workflows.
- **Commands** — the real build/test/run commands, pulled from scripts and build
  files rather than assumed.
- **Prerequisites** — SDK/runtime versions, required global tools, package sources,
  credentials.
- **Configuration** — environment variables and config files the app reads.
- **Docs** — where deeper documentation already lives, to link rather than restate
  (and confirm it actually exists before adding a pointer).

Then write a README that covers the orientation checklist, arranged however suits
the repo, keeping every command copy-paste-ready and every prerequisite specific
(real version numbers, real package source URLs). Include only the checklist items
that apply.

## Auditing an existing README

When the file already exists, the job is accuracy, **not** redesign.

- **Do not restructure or reformat.** Match the existing structure. Larger
  formatting or organizational changes are out of scope unless the user explicitly
  asks for them. The user chose that structure; respect it.
- **Verify every concrete claim** against the current repo: do the prerequisites,
  setup tasks, and commands still match what the build files and scripts say?
  Are version numbers current? Do referenced docs and paths still exist?
- **Use orientation as the audit lens:** walk the README as a newcomer would and
  find where it would leave them stuck, misled, or unable to get the project
  running. Stale commands, missing prerequisites, renamed scripts, removed config,
  and links to docs that no longer exist are the usual culprits.
- **A missing optional section is not automatically a defect.** Judge gaps by
  whether they actually impair orientation for this repo — don't flag the absence
  of a TOC, a docs section, or a contributing section as a problem unless its
  absence genuinely leaves a newcomer stuck.
- **Report findings, then fix only inaccuracies** after confirmation — surgical
  edits that correct wrong or missing information, not a rewrite.
