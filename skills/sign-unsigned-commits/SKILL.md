---
name: sign-unsigned-commits
description: Retroactively sign unsigned commits on the current git branch that were authored by the current git user. Use this skill whenever the user mentions signing previously-unsigned commits, fixing commit signatures, re-signing commits that were made without GPG/SSH signing, or any phrase like "sign my commits", "these commits aren't signed", "fix the signatures on this branch", "I need to sign the commits from earlier", or "clean up the unsigned commits". A common trigger scenario: Claude Code ran autonomously, hit a signing-key-locked error (e.g. 1Password locked, SSH agent missing, GPG passphrase timeout), fell back to `-c commit.gpgsign=false` to keep making progress, and now the user is back at the keyboard and wants to sign those commits. Trigger this skill proactively when you see unsigned commits on the current branch and the user starts talking about signing or signatures — don't wait for a literal "please sign".
---

# sign-unsigned-commits

Retroactively sign commits on the current branch that are missing signatures and were authored by the current git user. This is a history-rewriting operation — work through it carefully, and stop to ask the user at the checkpoints called out below.

## What this skill does and doesn't touch

- **Touches:** commits in `BASE..HEAD` where signature status is `N` (no signature) AND author email matches `git config user.email`.
- **Leaves alone:** signed commits, commits by other authors, anything outside the current branch's exclusive range.
- **Side effect to be honest about:** because `git rebase` replays every commit from the rebase base forward, commit hashes change for *every* commit in the replayed range — even ones the skill doesn't modify. To minimize blast radius, the rebase base is the parent of the *earliest* unsigned-by-user commit, not the merge-base with main.

Tell the user about this side effect before you run the rebase. It's the kind of thing that's obvious to anyone who's written rebase code but surprising to everyone else.

## Prerequisites to verify before touching history

Run these checks first. If any fail, stop and report — don't try to paper over a misconfiguration by rewriting commits.

1. **Signing config exists.**
   ```bash
   git config --get user.signingkey
   git config --get commit.gpgsign
   git config --get gpg.format      # ssh, openpgp, x509
   ```
   If `user.signingkey` is empty, stop and ask the user what key they expect to sign with.

2. **Working tree is clean.**
   ```bash
   git status --porcelain
   ```
   Must be empty. Rebase refuses to start otherwise. If there are local changes, stop and ask the user how to proceed (stash vs. commit vs. abort the whole skill).

3. **We're not already mid-rebase / mid-merge.**
   ```bash
   git rev-parse --git-path rebase-merge
   git rev-parse --git-path rebase-apply
   git rev-parse --git-path MERGE_HEAD
   ```
   If any of those paths exist as real files/dirs, stop — there's in-progress state the user needs to resolve first.

## Step 1 — capture the user and branch

```bash
git rev-parse --abbrev-ref HEAD          # current branch
git config --get user.email              # target author
```

Save both values. The email will be inlined into the rebase helper script in Step 5.

## Step 2 — find unsigned commits by the user

Pick a base for the range `$BASE..HEAD`, preferring in this order:

1. Upstream tracking branch, if set: `git rev-parse --abbrev-ref '@{upstream}'`
2. Merge-base with `main`: `git merge-base HEAD main`
3. If neither works (no upstream, no `main`), ask the user what base to use. Don't guess.

Capture the chosen base in a shell variable so the rest of the skill's commands are
self-contained:

```bash
BASE=<result of whichever option succeeded above>
```

Then list candidate commits:

```bash
git log --pretty='format:%H %G? %ae %s' "$BASE..HEAD"
```

`%G?` signature codes: `G` good, `B` bad, `U` unknown validity, `N` no signature, `E` can't check, `X`/`Y`/`R` various expired/revoked states. You want rows where the code is **exactly `N`** AND the author email matches `user.email`.

Show the filtered list to the user (short SHAs + subjects) so they can sanity-check what's about to be rewritten. If the list is empty, stop and tell them there's nothing to sign — don't run the rebase just to be thorough.

## Step 3 — push safety check

```bash
git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null
```

If this returns an upstream, the branch has been pushed somewhere. **Stop and ask before proceeding.** Rewriting history on a pushed branch means a force-push, which can stomp on collaborators or CI. Present to the user:

- The upstream ref name
- The list of commits that will be rewritten (from Step 2)
- The reminder that hashes change for *every* commit from the earliest unsigned-by-user commit forward, not just the ones being signed
- A clear "this will require `git push --force-with-lease` afterward — proceed?" question

Only continue on an explicit yes. If there's no upstream, you can skip this checkpoint and proceed.

## Step 4 — prove signing works *now*

Before rewriting anything, verify the signer is actually unlocked and functional. A failed rebase mid-flight leaves the branch in a partial state that's annoying to recover from, and the whole point of this skill is that earlier signing failed — don't assume it's working now.

```bash
git commit --allow-empty -S -m "signing test" && git reset --hard HEAD~1
```

If the commit fails (gpg error, 1Password prompt timing out, SSH agent missing), stop. Tell the user to unlock 1Password / start the agent / fix whatever's wrong, and re-run the skill. Do not proceed to Step 5.

If the commit succeeds, the `git reset --hard HEAD~1` removes the test commit and you're ready.

## Step 5 — rewrite history

Find the earliest unsigned-by-user commit from Step 2. Its parent is the rebase base. Write a small helper script that conditionally re-signs, then run rebase with `--exec` pointing at it:

```bash
EARLIEST=<sha of earliest unsigned-by-user commit from Step 2>
TARGET_EMAIL="$(git config user.email)"

cat > /tmp/sign-if-needed.sh <<EOF
#!/bin/sh
STATUS=\$(git log -1 --pretty=format:%G?)
EMAIL=\$(git log -1 --pretty=format:%ae)
if [ "\$STATUS" = "N" ] && [ "\$EMAIL" = "$TARGET_EMAIL" ]; then
  git commit --amend --no-edit -S
fi
EOF
chmod +x /tmp/sign-if-needed.sh

git rebase --exec '/tmp/sign-if-needed.sh' "$EARLIEST^"
```

Why this shape:
- The helper script runs once per replayed commit. It checks the *current* HEAD's signature status and author email. If both conditions match, it amends with `-S` (which re-signs). Otherwise it's a no-op and rebase moves on.
- `--no-edit` keeps the commit message. `-S` is redundant if `commit.gpgsign=true` globally, but explicit is better here — we want signing even if the user's config was temporarily toggled off.
- **No `-n` / `--no-verify`.** Hooks run normally during the amend. The user specifically wants this — if a pre-commit hook would have caught something, it should still catch it now.
- The heredoc uses unquoted `EOF` so `$TARGET_EMAIL` is inlined at write-time, while `\$STATUS` and `\$EMAIL` stay escaped for runtime expansion inside the script.
- Basing the rebase at `$EARLIEST^` (not at the branch's merge-base) limits the hash-rewrite blast radius to just the range from the first unsigned-by-user commit forward.

If the rebase errors partway through, **stop and report to the user**. Don't reflexively `git rebase --abort` — they may want to inspect the in-progress state first. Ask what they want to do.

## Step 6 — verify

After a successful rebase, re-run the Step 2 query:

```bash
git log --pretty='format:%H %G? %ae %s' "$BASE..HEAD"
```

Every row that previously showed `N` for a user-authored commit should now show `G`. If any still show `N`, something went wrong — report the remaining rows to the user and stop.

Also run a human-readable check:

```bash
git log --show-signature "$BASE..HEAD" | head -60
```

so the user can eyeball the actual signature lines.

Clean up the helper:

```bash
rm -f /tmp/sign-if-needed.sh
```

## Step 7 — push (user runs this themselves)

If the branch was pushed and the user authorized rewriting in Step 3, they now need to force-push. **Don't run the push yourself.** Suggest the exact command and let them execute it:

```bash
git push --force-with-lease
```

`--force-with-lease` is safer than plain `--force`: it refuses to overwrite the remote if someone else has pushed since your last fetch. If the user insists on plain `--force`, defer to them — but mention the lease variant first.

## Things not to do

- **Don't** use `--no-verify` / `-n`. Hooks must run.
- **Don't** touch commits authored by anyone other than the current git user, even if they're unsigned.
- **Don't** widen the scope to signed commits "just to be consistent" — wastes hook runs and can fail on commits with issues you didn't cause.
- **Don't** force-push on the user's behalf. Ever. That's their call.
- **Don't** try to recover from a failed mid-rebase by guessing. Stop and ask.
- **Don't** run this skill if Step 4's signing test fails. The whole premise is that signing works now; verify it before rewriting anything.
