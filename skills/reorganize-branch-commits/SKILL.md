---
name: reorganize-branch-commits
description: Reorganize the commits on a non-default git branch into a clean, logical history by rewriting the branch — `git reset` + re-commit by default, scripted `git rebase -i` when existing commit boundaries already align. Propose groupings based on the actual work done (features, refactors, tests, fixes, docs), get explicit user approval, then rewrite history while re-signing the new commits and running hooks. Use this skill whenever the user wants to tidy up, clean up, reorganize, restructure, squash, reshape, or curate commits on a feature branch — even if they phrase it as "my branch is a mess", "the history is ugly", "let's squash this down", "combine these commits", "fix up the commit log before I open a PR", "organize this into logical commits", "interactive rebase and group these", or "make the commits presentable for review". Trigger proactively when the user is about to open or push a PR and the branch has scrappy/WIP/"fix" commits that should be collapsed into meaningful units. Refuses to operate on default or release-shaped branches (main, master, develop, trunk, production, release, or the repo's configured default) — this is a feature-branch-only tool.
---

# reorganize-branch-commits

Restructure the commits on a non-default branch into a clean, logical history. Two jobs: (1) propose a grouping grounded in the actual diffs, and (2) execute the rewrite safely — default branches refused, backup first, new commits re-signed, hooks run.

This is history-rewriting. Every commit from `BASE` forward gets a new hash, even ones not being restructured, because both strategies rebuild the range from scratch. Existing signatures don't carry across — every commit in the replayed range is a new commit and has to be re-signed. Say so up front.

## Prerequisites

Stop and report if any fail — don't paper over them.

1. **Clean working tree:** `git status --porcelain` must be empty. A dirty tree is dangerous both ways: rebase refuses unstaged tracked changes, and Strategy A's reset would silently blend uncommitted edits into the reorganized commits. If there are local changes, ask how to proceed (stash, commit, abandon).

2. **Not mid-operation:**
   ```bash
   GIT_DIR=$(git rev-parse --git-dir)
   [ -d "$GIT_DIR/rebase-merge" ] || [ -d "$GIT_DIR/rebase-apply" ] \
     || [ -f "$GIT_DIR/MERGE_HEAD" ] || [ -f "$GIT_DIR/CHERRY_PICK_HEAD" ]
   ```
   If the test returns true (any of those paths exists), stop — the user has in-progress rebase/merge/cherry-pick state to resolve first. (Don't use `git rev-parse --git-path <path>` with multiple args here: `--git-path` takes a single path, so extra arguments are silently parsed as refs and the subsequent checks don't do what they look like.)

3. **Signing config present if signing is expected:** `git config --get user.signingkey` and `commit.gpgsign`. Don't silently produce unsigned commits in a repo that signs.

## Step 1 — refuse the default branch

Non-negotiable. Run first.

```bash
CURRENT=$(git rev-parse --abbrev-ref HEAD)
```

**Detached HEAD** (`CURRENT` == `"HEAD"`): stop. The backup ref, the rewrite, and the push all need a named branch. Ask the user to check out or create one.

**Danger list** (`main`, `master`, `trunk`, `develop`, `production`, `release`): stop regardless of what the repo's detected default is. These names are too load-bearing to ever touch from this skill.

Then detect the default branch, trying in order:

```bash
git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null | sed 's@^origin/@@'
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null
# fallback: check which of main/master/trunk/develop exists locally
```

Call the result `DEFAULT`. If `CURRENT == DEFAULT`, stop. If `DEFAULT` couldn't be determined, ask — don't guess.

## Step 2 — pick the base

Prefer in order:

1. `git merge-base HEAD "origin/$DEFAULT"` (fork point) — prefer the remote-tracking ref since `$DEFAULT` was detected via `origin/HEAD` and a local branch named `$DEFAULT` may not exist. If there's no remote and `$DEFAULT` exists locally, use `$DEFAULT` instead.
2. An explicit base the user supplies (e.g., branch stacked on another feature branch)
3. If `@{upstream}` has commits the local branch doesn't, surface that — they may want to rebase against upstream first

Capture `BASE` and show the user `BASE`, `CURRENT`, and `git rev-list --count "$BASE..HEAD"`. If the count is 0 or 1, stop — nothing to reorganize.

## Step 3 — inventory the branch

```bash
git log --pretty='format:%H %G? %an <%ae> %ad %s' --date=short "$BASE..HEAD"
git log --name-status --pretty='format:=== %H %s' "$BASE..HEAD"
```

Pull `git diff "$BASE..HEAD"` for any commit whose intent isn't obvious from the file list. For large ranges, do this selectively rather than loading the full diff.

Flag anything that constrains the proposal:

- **Multiple authors** — Strategy A re-attributes to the current user. Use Strategy B or `Co-authored-by:` trailers.
- **Merge commits** (`git log --merges "$BASE..HEAD"`) — both strategies flatten them. This skill does not preserve merges during reorganization. If the user wants them preserved, stop — direct them to a hand-rolled `git rebase -i --rebase-merges "$BASE"`.
- **Signed commits** — they'll need re-signing after the rewrite.

## Step 4 — propose logical groupings

Ground the proposal in the diffs, not the existing messages ("wip", "fix typo", "oops" lie; the diffs don't).

Heuristics:
- **One logical change per commit.** Describable in one sentence without "and".
- **Separate by concern:** feature code, tests, refactors, unrelated fixes, docs, tooling.
- **Pure refactors go before the feature that needs them.**
- **"fix typo" / "address review" / "wip"** fold into the commit whose intent they serve.
- **Mirror repo conventions.** Check `git log "origin/$DEFAULT" -20 --oneline` (or `"$DEFAULT"` locally if there's no remote) for subject style (conventional-commits prefixes, scopes, issue refs). Don't invent a new convention.

Present exactly like this so the user can edit it:

```
Proposed history (BASE → HEAD), N commits:

1. <subject>
   Rationale: <why these belong together>
   Source commits: <short SHAs folded in>
   Files: <representative paths/prefixes>

2. <subject>
   ...
```

Call out any tradeoffs you made.

## Step 5 — approval checkpoint

No yes, no proceed. Iterate on the proposal until the user's satisfied (reword, split, merge, reorder, pass-through). Also lock in the answers you'll need later:

- **Author preservation?** (Strategy choice hinges on this.)
- **Signing?** (Usually yes if the repo signs; confirm rather than assume.)
- **Force-push afterward?** (Step 10 — get the answer now.)

## Step 6 — safety backup

```bash
git branch "backup/${CURRENT}/$(date -u +%Y%m%dT%H%M%SZ)"
```

Tell the user the backup branch name — recovery is `git reset --hard <backup-branch>`. Reflog retains the original HEAD ~90 days as a last-resort fallback, but don't plan around it.

## Step 7 — push safety check

```bash
git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null
```

If there's an upstream, the branch is pushed. Stop and confirm with the user: show the upstream ref, note that finishing this requires `git push --force-with-lease`, and warn that PR review comments anchored to old line numbers may become orphaned. Get an explicit "proceed".

## Step 8 — rewrite history

Capture the pre-rewrite HEAD so Step 9 has something to compare against:

```bash
ORIG=$(git rev-parse HEAD)
```

Default to **Strategy A**. Use **Strategy B** only when existing commit boundaries already match the desired groupings or author metadata must be preserved.

### Strategy A — collapse and rebuild

`git reset "$BASE"` (default `--mixed`) moves HEAD to `BASE`, resets the index to match, and leaves the working tree alone — so every change from `BASE..ORIG` is now an unstaged edit ready to be re-grouped.

```bash
git reset "$BASE"

# subject-only commit
git add <paths for group 1>
git commit -S -m "<subject 1>"

# subject + body (or Co-authored-by: trailers): use -F -
git add <paths for group 2>
git commit -S -F - <<'EOF'
<subject 2>

<body / issue refs / Co-authored-by: trailers>
EOF
```

- `-S` forces signing even if `commit.gpgsign` is off; drop it if the repo doesn't sign.
- No `--no-verify`. Hooks run.
- If a file has hunks belonging to two groups, `git add -p <file>`. If the split isn't obvious, walk it with the user.

Verify the tree, then interpret:

```bash
git diff "$ORIG" HEAD
```

- **Empty** — clean rewrite. Go to Step 9.
- **Non-empty** — investigate. Two legitimate causes:
  - **Real miss:** a hunk didn't get staged into any group. Either stage it into a new commit or `git reset --hard <backup-branch>` and restart.
  - **Hook-induced:** formatters/codegen/license-headers reshaped the tree. Expected if any original commit used `--no-verify`. Eyeball each hunk with the user — if it's all clearly formatter output, proceed; if any of it looks like user-authored content, stop.

Never auto-push on a non-empty diff.

### Strategy B — scripted interactive rebase

Feed a pre-written todo non-interactively. Use a repo-scoped temp path so concurrent reorganizations in sibling worktrees don't clobber each other's todo file:

```bash
REBASE_TODO="$(git rev-parse --git-dir)/rebase-todo-skill"

cat > "$REBASE_TODO" <<'EOF'
pick   <sha1>   original subject
exec   git commit -S --amend -m "<new subject for group 1>"
fixup  <sha2>
fixup  <sha3>
pick   <sha4>   original subject
exec   git commit -S --amend -m "<new subject for group 2>"
fixup  <sha5>
EOF

GIT_SEQUENCE_EDITOR="cp $REBASE_TODO" GIT_EDITOR="true" \
  git -c commit.gpgsign=true rebase -i "$BASE"
```

Prefer `fixup` over `squash` for any commit you want folded into the group above: `squash` opens the message editor, and with `GIT_EDITOR="true"` that editor exits immediately — the resulting message is the auto-concatenation of the two commits' original messages, not the subject you set via `exec ... --amend`. If you specifically need `squash` (to hand-edit the combined message), follow it with another `exec git commit -S --amend -m "..."` to restore the intended subject.

`GIT_EDITOR="true"` suppresses the message editor that `reword`/`squash` would otherwise pop. Using `exec git commit -S --amend -m` right after a `pick` is the cleanest way to rewrite subjects without interactive editing. Authorship from `pick` is preserved; `fixup` keeps its target's metadata.

Signing note: unlike Strategy A's explicit `-S` on every commit, rebase replay obeys `commit.gpgsign`, and `exec git commit --amend` is an independent commit that doesn't inherit the rebase's settings. So **both** are needed: `-c commit.gpgsign=true` on the rebase ensures every replayed `pick`/`fixup`/`squash` is signed, and `-S` on each `exec ... --amend` signs the subject rewrites. If the repo doesn't sign, drop both.

If the rebase halts on a conflict, don't auto-resolve. Stop, report the conflicting paths, and let the user choose: resolve and `git rebase --continue`, or `git rebase --abort` (the backup from Step 6 is still there either way).

### If anything goes sideways

Stop. Don't reflexively `git rebase --abort`. Offer the backup branch for a clean rewind:

```bash
git reset --hard <backup-branch>
```

## Step 9 — verify

1. **Tree matches ORIG** (Strategy A did this in-flow; Strategy B hasn't):
   ```bash
   git diff "$ORIG" HEAD
   ```
   Same triage as Step 8 on a non-empty result.

2. **Signatures on every commit:**
   ```bash
   git log --pretty='format:%h %G? %s' "$BASE..HEAD"
   ```
   Every row should show `G` (or the expected status for this repo). Any `N` on a signing repo means something's wrong — report and stop.

3. **Subjects read well:**
   ```bash
   git log --oneline "$BASE..HEAD"
   ```
   Show the user. For last-mile subject tweaks, `git rebase -i "$BASE"` with `reword` handles them cleanly on the new history.

## Step 10 — push (user runs this)

Don't run the push. Suggest the command:

```bash
git push --force-with-lease   # with upstream, approved in Step 7
git push -u origin "$CURRENT" # no upstream
```

Lead with `--force-with-lease` over plain `--force` — it refuses to overwrite the remote if someone else pushed since your last fetch. Mention this even if the user asks for plain `--force`.

## Things not to do

- **Don't** run on any default branch (`main`, `master`, `develop`, `trunk`, `production`, `release`, or the detected default). Step 1 is a hard stop.
- **Don't** use `--no-verify`. A failing hook is signal; fix the content.
- **Don't** force-push on the user's behalf. Their call, their command.
- **Don't** propose groupings from commit messages alone — diffs are the ground truth.
- **Don't** silently drop commits. Every commit in `BASE..HEAD` must be accounted for in the proposal, even if "pass through unchanged".
- **Don't** invent a commit-message convention. Mirror the repo's.
- **Don't** try to recover from a failed rebase by guessing. Stop, surface the backup branch name, let the user decide.
