---
name: clean-unused-cpm-packages
description: Remove unused PackageVersion entries from `Directory.Packages.props` files in a .NET repo using Central Package Management (CPM). Scans every `.csproj`, `.props`, and `.targets` file for PackageReference includes, computes which PackageVersion IDs aren't referenced anywhere, removes the unused entries with line-targeted edits that preserve formatting and comments, then verifies with `dotnet restore`. Use this skill whenever the user wants to clean up, prune, or remove unused entries from `Directory.Packages.props`, or says things like "clean up CPM", "remove unused packages from central package management", "the props file has stale entries", "prune Directory.Packages.props", or "dead packages in the central versions file" — even if they don't literally say "CPM". Trigger proactively when the user mentions `Directory.Packages.props` alongside cleanup, removal, dead, stale, or unused. Refuses to run on repos without a `Directory.Packages.props` (CPM not in use).
---

# clean-unused-cpm-packages

Remove `<PackageVersion>` entries from `Directory.Packages.props` files when no project, `.props`, or `.targets` file in the repo references the corresponding package. Conservatively compute the unused set by scanning every place a `PackageReference` could live, then make the smallest edits possible while preserving comments, blank lines, and hand-curated grouping.

This is a destructive operation against tracked source files. Work through the steps carefully, stop at the confirmation checkpoint, and verify with `dotnet restore` before declaring success.

## What this skill scans

**`PackageVersion` sources** (entries considered for removal):

- Every `Directory.Packages.props` in the repo, including nested ones.

**`PackageReference` sources** (anything that "uses" a `PackageVersion`):

- Every `.csproj`.
- Every `.props` and `.targets` file *other than* `Directory.Packages.props` itself — including `Directory.Build.props`, `Directory.Build.targets`, and any custom imports.

**Excluded from removal:**

- `<GlobalPackageReference>` entries. They auto-apply to every project — the entry itself *is* the reference. Removing one drops an analyzer/generator from every project, which is a deliberate user decision, not something to automate.
- Conditional entries (`<PackageVersion ... Condition="..." />`): treat them like any other entry. The condition gates when the version applies, not whether the package is referenced — so if no project references the ID, the entry is unused regardless of the condition.

## Prerequisites

Stop and report if any fail.

1. **CPM is in use.** At least one `Directory.Packages.props` exists in the repo:

   ```bash
   find . -type f -name 'Directory.Packages.props' \
     -not -path '*/node_modules/*' -not -path '*/bin/*' -not -path '*/obj/*'
   ```

   If none, this isn't a CPM repo — stop and tell the user.

2. **Working tree is clean for the files this skill will touch.**

   ```bash
   git status --porcelain -- ':(glob)**/Directory.Packages.props'
   ```

   The `:(glob)` magic is required so the pathspec crosses directory boundaries — without it, nested `Directory.Packages.props` files aren't checked. If any have uncommitted edits, ask before mixing in the skill's changes.

3. **`dotnet` is on PATH.** The Step 6 verification depends on it; the skill does not run without it:

   ```bash
   dotnet --version
   ```

   If `dotnet` is missing or fails, stop and ask the user to install/fix it before re-running.

4. **No `.fsproj` or `.vbproj` projects in the repo.** This skill only scans `.csproj`. References held by F#/VB projects won't be counted, and `PackageVersion` entries used only by them would be wrongly flagged as unused:

   ```bash
   find . -type f \( -name '*.fsproj' -o -name '*.vbproj' \) \
     -not -path '*/node_modules/*' -not -path '*/bin/*' -not -path '*/obj/*'
   ```

   If any are found, warn the user that references in those projects won't be detected and ask whether to proceed regardless.

## Step 1 — collect every `PackageVersion` and `GlobalPackageReference`

For each `Directory.Packages.props` file, read it and record:

- Each `<PackageVersion>` entry: package ID, version, and source file.
- Each `<GlobalPackageReference>` entry: same, but tagged "global" so Step 3 skips it.

Multi-line entries (rare, but valid) span multiple lines — capture the whole block. Conditional entries (`Condition="..."`) are captured like any other.

## Step 2 — collect every `PackageReference` Include across the repo

Search in:

- All `.csproj` files.
- All `.props` and `.targets` files **other than** `Directory.Packages.props` files.

Exclude build output and dependency directories: `bin/`, `obj/`, `node_modules/`, `.git/`. Files under those (e.g. `obj/*.g.props`) hold generated `PackageReference` entries that don't reflect actual project intent and would mask legitimately-unused entries.

For each remaining file, find every `<PackageReference>` element and pull its `Include` (or `Update`) attribute value. `Update` modifies metadata of an existing reference and still counts as a reference. Use multiline-aware matching: `<PackageReference>` attributes can spill across lines.

Build a deduped set of referenced package IDs. Compare case-insensitively: NuGet package IDs are case-insensitive, so a `Directory.Packages.props` entry of `Microsoft.Extensions.Hosting` and a project file with `microsoft.extensions.hosting` describe the same package — they must match. Keep the original casing for any displayed names and for the line edits in Step 5.

## Step 3 — compute the unused set

For each `PackageVersion` from Step 1: if its ID is not in the Step 2 set, it's unused.

`GlobalPackageReference` entries are skipped — they're never proposed for removal.

If the unused set is empty, tell the user there's nothing to remove and stop.

## Step 4 — show the proposal and STOP

Print the proposed removals grouped by source file, sorted by package ID:

```
[<path/to/Directory.Packages.props>]
  - SomePackage.A   (1.2.3)
  - SomePackage.B   (4.5.6)

[<path/to/other/Directory.Packages.props>]
  - SomePackage.C   (7.8.9)

3 unused PackageVersion entries.
```

Ask: *Remove these N entries?*

Wait for explicit confirmation. Reasons the user might decline:

- A package referenced via dynamic MSBuild item construction inside a `<Target>` — grep won't find that.
- A package referenced from a custom SDK or imported `.targets` outside the repo.
- A package the user knows is about to be re-added.

If the user asks for a diff first, produce a unified diff per file and re-prompt. Do not edit anything until confirmed.

## Step 5 — remove with targeted line edits

For each unused entry, locate the exact line(s) in its source file and remove them with `Edit`. Preserve:

- Comments above or beside the entry, *unless* the comment explicitly belongs to the removed entry (e.g. `<!-- SomePackage.A: pinned for compat -->` directly above the line). When in doubt, leave the comment.
- Blank lines used for grouping.
- Surrounding XML — don't merge sibling elements onto one line.

Multi-line entries: remove the whole block.

Do not reformat the rest of the file. The goal is the minimum change that drops the listed entries.

## Step 6 — verify with `dotnet restore`

Run from the repo root (or each affected solution root, if the repo has multiple):

```bash
dotnet restore
```

If restore succeeds, the cleanup is verified. Summarize what was removed and stop.

If restore fails, the cause is almost always one of:

- **Reference lives somewhere the scan missed** — `.fsproj`/`.vbproj` (this skill is `.csproj`-only — Prereq 4 should have surfaced this), an MSBuild SDK imported from outside the repo, `.targets` generated at build time, or props injected by another NuGet package.
- **Reference is constructed dynamically by MSBuild** — `PackageReference` items added inside a `<Target>` or via a conditional `<ItemGroup>` evaluated only at build time. Grep doesn't see those.

Re-add the specific wrongly-removed entry by hand. Use `git diff <file>` to see what was removed and selectively restore just that line. **Don't** `git checkout -- <file>` — that discards every correctly-removed entry along with the false positive. Tell the user which package was wrongly flagged so the edge case is visible.

## Things not to do

- **Don't** reformat `Directory.Packages.props`. The file is curated by hand; preserve comments, grouping, and blank lines.
- **Don't** flag `GlobalPackageReference` entries as unused. They're always used — removing one is a deliberate user decision.
- **Don't** proceed past Step 4 without explicit user confirmation. Edits to tracked source files are a destructive action.
- **Don't** widen the scan to `.fsproj` or `.vbproj`. This skill is `.csproj`-only by design.
- **Don't** parse-and-reserialize the XML (e.g. `[xml]` in PowerShell, `xml.etree` in Python). It loses comments and reformats whitespace. Always use line-targeted edits.
- **Don't** "fix" unused-by-grep false positives by removing the entries anyway. If `dotnet restore` fails after a removal, restore the entry — the failure is the signal.
