---
name: reorganize-branch-commits
description: Reorganize the commits on a non-default git branch into a clean, logical history via interactive rebase. Propose groupings based on the actual work done (features, refactors, tests, fixes, docs), get explicit user approval, then rewrite history while preserving signatures and running hooks. Use this skill whenever the user wants to tidy up, clean up, reorganize, restructure, squash, reshape, or curate commits on a feature branch — even if they phrase it as "my branch is a mess", "the history is ugly", "let's squash this down", "combine these commits", "fix up the commit log before I open a PR", "organize this into logical commits", "interactive rebase and group these", or "make the commits presentable for review". Trigger proactively when the user is about to open or push a PR and the branch has scrappy/WIP/"fix" commits that should be collapsed into meaningful units. Refuses to operate on default branches (main, master, develop, trunk, or the repo's configured default) — this is a feature-branch-only tool.
---

# reorganize-branch-commits

Restructure the commits on a non-default branch into a clean, logical history. This is a history-rewriting operation — the payoff is a reviewable log, but the cost is that every commit in the replayed range changes hash. Work through the steps carefully and stop at the checkpoints.

The skill's job is two things: (1) propose a logical grouping of the branch's work, grounded in the actual diffs, and (2) execute the rewrite safely — backup first, signing preserved, hooks run, default branches refused.

## What this skill does and doesn't touch

- **Touches:** commits in `BASE..HEAD` on the current non-default branch, where `BASE` is the fork point with the repo's default branch (or an explicit base the user provides).
- **Leaves alone:** the default branch itself, any commits before `BASE`, commits on other branches.
- **Hard refusal:** if `HEAD` resolves to the default branch (or any common default-ish name), the skill stops immediately. This tool is for feature branches. Reorganizing `main` is not a scenario this skill supports — ask the user to point it at the right branch.
- **Side effect to be honest about:** every commit from `BASE` forward gets a new hash, even commits that aren't being restructured, because the rebase replays them all. Tell the user up front.

## Prerequisites to verify before touching history

If any of these fail, stop and report — don't paper over them by rewriting anyway.

1. **Working tree is clean.**
   ```bash
   git status --porcelain
   ```
   Must be empty. Rebase refuses to start otherwise. If there are local changes, ask the user how to proceed (stash, commit, abandon).

2. **Not already mid-rebase / mid-merge / mid-cherry-pick.**
   ```bash
   git rev-parse --git-path rebase-merge
   git rev-parse --git-path rebase-apply
   git rev-parse --git-path MERGE_HEAD
   git rev-parse --git-path CHERRY_PICK_HEAD
   ```
   If any of those paths exist as real files/dirs, stop — the user has in-progress state to resolve first.

3. **Signing config exists if the existing commits are signed.** The user's global CLAUDE.md may require signed commits. Check:
   ```bash
   git config --get user.signingkey
   git config --get commit.gpgsign
   ```
   If signing is expected but misconfigured, stop and report — don't silently produce unsigned commits.

## Step 1 — refuse to operate on the default branch

This check is non-negotiable. Run it first, before anything else.

```bash
CURRENT=$(git rev-parse --abbrev-ref HEAD)
```

Determine the default branch name. Try in order:

1. Remote HEAD symbolic ref:
   ```bash
   git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null | sed 's@^origin/@@'
   ```
2. `gh` if available:
   ```bash
   gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null
   ```
3. Check which of `main`, `master`, `trunk`, `develop` exists locally as a fallback.

Call the result `DEFAULT`. Then:

- If `CURRENT` equals `DEFAULT`: **stop**. Tell the user this skill refuses to rewrite the default branch, and ask them to check out a feature branch first.
- If `CURRENT` is in the hardcoded danger list `{main, master, trunk, develop, production, release}` even when it's not the detected default: **stop**. Same message. These names are too load-bearing to ever touch without an explicit out-of-band instruction.
- If `DEFAULT` could not be determined: stop and ask the user what the default branch is. Don't guess — getting this wrong means running the skill on the wrong branch.

Only continue on a non-default, named feature branch.

## Step 2 — pick the base

The rebase base is where the feature branch diverged from the default. Prefer in order:

1. `git merge-base HEAD "$DEFAULT"` — the fork point.
2. If the user has specified a different base (e.g., the branch was built on top of another feature branch), use that.
3. If the upstream is meaningfully different (`git rev-parse --abbrev-ref '@{upstream}'`) and contains commits not in the local branch, surface that to the user — they may want to rebase against upstream first.

Capture:

```bash
BASE=<the chosen base SHA>
```

Show the user: `BASE`, `CURRENT`, and the commit count (`git rev-list --count "$BASE..HEAD"`). If the count is 0 or 1, stop — there's nothing to reorganize.

## Step 3 — inventory the branch

Before you can propose a grouping, you have to understand what's actually there. Collect:

```bash
# commit log with authors and signature status
git log --pretty='format:%H %G? %an <%ae> %ad %s' --date=short "$BASE..HEAD"

# files touched across the whole range
git diff --name-status "$BASE..HEAD"

# per-commit file lists
git log --name-status --pretty='format:=== %H %s' "$BASE..HEAD"

# the full diff, so the grouping is grounded in real content not just filenames
git diff "$BASE..HEAD"
```

For large ranges, read the per-commit log first, then pull targeted diffs for commits you're unsure how to categorize rather than loading the full diff at once.

Note anything that will constrain the proposal:
- **Multiple authors** — a soft-reset rebuild will re-attribute commits to the current user. If co-authors matter, the rewrite must use interactive rebase (Strategy B below) to preserve author metadata, or add `Co-authored-by:` trailers.
- **Merge commits** in the range — a branch that contains merges from main partway through complicates the rebase. Surface this to the user and ask whether to flatten (default) or preserve merges.
- **Signed commits** — they'll need re-signing after the rewrite.

## Step 4 — propose logical groupings

Draft a restructured commit list based on the diffs, not just the existing commit messages. The existing messages may be noisy ("wip", "fix typo", "oops"); the diffs are the ground truth.

Good grouping heuristics:
- **One logical change per commit.** A commit should be describable in one sentence without "and".
- **Separate concerns by type:** feature code, tests for that feature, refactors, unrelated fixes, docs, config/tooling changes.
- **Tests for a feature can live with the feature** (one commit) or immediately after (two commits) — ask the user's preference if it's not obvious from repo conventions.
- **Pure refactors go before the feature that depends on them** so the feature commit stays focused.
- **"fix typo", "address review", "wip"** commits should fold into the commit whose intent they serve.
- **Mirror the repo's existing conventions.** Check recent commits on the default branch (`git log "$DEFAULT" -20 --oneline`) for subject style — conventional-commits prefixes, sentence case, scope prefixes, issue numbers, etc. Match what's there. Don't invent a new convention.

Present the proposal in this exact shape so the user can scan and edit it:

```
Proposed history (BASE → HEAD), N commits:

1. <proposed subject>
   Rationale: <why these belong together>
   Source commits: <short SHAs being folded in>
   Files: <representative paths or prefixes>

2. <proposed subject>
   ...
```

Include any notes about tradeoffs you made — e.g., "combined the two refactor commits because they both touch the same abstraction" or "kept the revert as its own commit because it's easier to spot in history".

## Step 5 — stop and get explicit approval

Do not proceed without a clear yes. The user may want to:
- Reword subjects
- Split a proposed commit
- Merge two proposed commits
- Reorder
- Exclude a commit from the rewrite entirely (pass it through as-is)

Iterate on the proposal until the user is satisfied. Only then move on.

Also confirm with the user:
- **Co-authors / author preservation?** If multiple authors in range, how to handle.
- **Signing expected on the output?** Almost always yes if the repo signs — but confirm rather than assume.
- **Force-push afterward?** (See Step 9.) Get the answer now so you're not asking mid-flow.

## Step 6 — create a safety backup

Before rewriting anything, create a backup ref. This is cheap, local, and saves you if something goes wrong:

```bash
git branch "backup/${CURRENT}/$(date -u +%Y%m%dT%H%M%SZ)"
```

Tell the user the backup branch name. If the rewrite goes sideways, recovery is `git reset --hard <backup-branch>`.

## Step 7 — push safety check

```bash
git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null
```

If the branch has an upstream, it's been pushed. Stop and confirm:

- Show the upstream ref.
- Remind the user that completing this will require `git push --force-with-lease` to update the remote.
- If there's an open PR, reviewers will see the force-push event; comments anchored to old line numbers may become orphaned.
- Get an explicit "proceed" before Step 8.

If no upstream, skip straight to Step 8.

## Step 8 — rewrite history

Pick the right strategy. Default to **Strategy A** (collapse-and-rebuild) unless you have a specific reason to use B.

### Strategy A — collapse and rebuild (default)

Use when the proposed grouping doesn't align with existing commit boundaries (the common case — that's usually why the user wants this skill).

```bash
# move to the base, keep all file changes in the index
git reset --soft "$BASE"

# un-stage everything so we can re-stage per logical group
git reset
```

Now the working tree holds every change from `BASE..originalHEAD`, nothing is staged, and `HEAD` is at `BASE`. Build each approved commit in order:

```bash
# group 1
git add <paths for group 1>
git commit -S -m "<approved subject for group 1>" \
  $( [ -n "$BODY1" ] && printf -- '-m %s' "$BODY1" )

# group 2
git add <paths for group 2>
git commit -S -m "<approved subject for group 2>"

# ... etc
```

Notes on this approach:
- `-S` forces signing even if `commit.gpgsign` is toggled off somewhere. If the user doesn't sign in this repo, drop it.
- **No `--no-verify`.** Hooks run normally. That's the point.
- If a file has changes belonging to two different groups, use `git add -p <file>` to stage hunks instead of the whole file. Stop and walk the user through the hunks if the split isn't obvious from the diff.
- Author metadata defaults to the current git user. If the original range had multiple authors and Step 5 said to preserve them, switch to Strategy B or add `Co-authored-by:` trailers to the relevant commits.

After all groups are committed, verify the tree matches what was there before:

```bash
git diff "originalHEAD" HEAD   # should be empty
```

If this diff is not empty, something was missed. Stop and report. Do not push.

(You can capture `originalHEAD` as a variable at the start of Step 8 with `ORIG=$(git rev-parse HEAD)` before the `reset --soft`.)

### Strategy B — interactive rebase with a scripted todo

Use when the existing commit boundaries already align with the desired groupings and you just need to squash/fixup/reword — or when author metadata must be preserved.

Write the desired todo list to a file and use `GIT_SEQUENCE_EDITOR` to feed it in non-interactively:

```bash
cat > /tmp/rebase-todo <<'EOF'
pick   <sha1>   <new subject for group 1>
fixup  <sha2>
fixup  <sha3>
pick   <sha4>   <new subject for group 2>
squash <sha5>
EOF

GIT_SEQUENCE_EDITOR="cp /tmp/rebase-todo" \
GIT_EDITOR="true" \
  git rebase -i "$BASE"
```

`GIT_EDITOR="true"` suppresses the message-editor that opens for `reword`/`squash`. That means subject changes need to happen differently: either rewrite after the rebase with `git commit --amend -m "..."` per commit (awkward for non-HEAD commits), or use `exec` lines in the todo to run `git commit --amend -m` right after each relevant pick. The cleanest pattern:

```
pick   <sha1>   original subject
exec   git commit --amend -m "new subject for group 1"
fixup  <sha2>
...
```

If the rebase stops with a conflict, don't auto-resolve. Stop and report to the user with the conflicting files and paths, and let them decide (resolve + `git rebase --continue`, or abort with `git rebase --abort` which restores the original branch since you made a backup in Step 6).

### If things go sideways

If anything errors during Step 8 and you're not sure how to recover: **stop**. Don't `git rebase --abort` reflexively — the user may want to inspect in-progress state first. The safety net is the backup branch from Step 6:

```bash
git reset --hard <backup-branch>
```

restores the original HEAD exactly.

## Step 9 — verify

After a successful rewrite, check:

1. **Tree is identical to before** (if you didn't already, and you still have the `ORIG` SHA):
   ```bash
   git diff "$ORIG" HEAD   # must be empty
   ```

2. **Commit count matches the proposal:**
   ```bash
   git rev-list --count "$BASE..HEAD"
   ```

3. **Signatures look right on every commit:**
   ```bash
   git log --pretty='format:%h %G? %s' "$BASE..HEAD"
   ```
   Every row should show `G` (or whatever the expected status is for this repo's signing setup). Any `N` on a branch that's supposed to sign means something went wrong — report and stop.

4. **Subjects read well end-to-end:**
   ```bash
   git log --oneline "$BASE..HEAD"
   ```
   Show this to the user. If they want to tweak a subject, `git rebase -i "$BASE"` with `reword` handles that cleanly on the new history.

## Step 10 — push (user runs this themselves)

If the branch has an upstream and the user approved force-push in Step 7, give them the command but don't run it yourself:

```bash
git push --force-with-lease
```

`--force-with-lease` is safer than `--force`: it refuses to overwrite the remote if someone else has pushed since your last fetch. Mention the lease variant first even if the user asks for plain `--force`.

If there's no upstream, a plain `git push -u origin "$CURRENT"` is fine.

## Things not to do

- **Don't** run on `main`, `master`, `develop`, `trunk`, `production`, `release`, or the detected default branch. Ever. Step 1 is a hard stop, not a warning.
- **Don't** use `--no-verify` / `-n`. Hooks must run. If a hook fails on the new commits, that's a real signal the groupings are wrong or the tree has a problem — fix it, don't skip it.
- **Don't** force-push on the user's behalf. That's their call and their command to run.
- **Don't** skip the backup branch in Step 6. It's three seconds of typing for unlimited undo.
- **Don't** propose a grouping based only on commit messages — read the actual diffs. Messages lie; diffs don't.
- **Don't** silently drop commits. If a commit in `BASE..HEAD` isn't represented somewhere in the proposal, that's a bug in the proposal — call it out explicitly rather than hoping the user notices.
- **Don't** invent a commit message convention. Mirror what the repo already uses.
- **Don't** try to recover from a failed rebase by guessing. Stop, tell the user the backup branch name, and let them decide.
