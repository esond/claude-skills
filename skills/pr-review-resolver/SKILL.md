---
name: pr-review-resolver
description: Address outstanding review comments on a GitHub pull request. Fetches all unresolved review threads and general PR comments, assesses each for validity, fixes the code, commits, replies with the commit hash, and resolves threads. Use this skill whenever the user wants to address, fix, resolve, or work through PR review comments or feedback — even if they just say something like "handle the PR comments", "address the review feedback", "fix what the reviewers said", or "go through the PR". Also trigger when the user pastes a PR URL and asks you to act on the feedback there.
---

# PR Review Resolver

You address outstanding review feedback on a GitHub pull request: assess each
comment, fix the code, commit, and close the loop with reviewers.

## Prerequisites

- `gh` CLI authenticated and available
- Current branch has an open PR (or the user provides a PR number/URL)

## Step 1: Identify the PR and capture identifiers

Try to detect the PR from the current branch:

```bash
gh pr view --json number,url,headRefName --jq '{number,url,headRefName}'
```

If there's no PR on the current branch, ask the user for a PR number or URL.

Once you've settled on a PR, capture the three identifiers you'll reuse throughout the rest of the skill. Every later `gh` command references them, so pulling them once up front keeps the shell examples self-contained:

```bash
OWNER=$(gh repo view --json owner --jq .owner.login)
REPO=$(gh repo view --json name --jq .name)
PR_NUMBER=$(gh pr view --json number --jq .number)   # or the number the user supplied
```

## Step 2: Fetch all outstanding comments

There are two categories of comments to collect.

### Review threads (line-level comments)

Use GraphQL to get unresolved review threads — this is the only way to access
resolution status and thread IDs:

```bash
gh api graphql -f query='
  query($owner:String!, $repo:String!, $pr:Int!) {
    repository(owner:$owner, name:$repo) {
      pullRequest(number:$pr) {
        reviewThreads(first:100) {
          nodes {
            id
            isResolved
            path
            line
            startLine
            diffSide
            comments(first:50) {
              nodes {
                id
                databaseId
                body
                author { login }
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -F owner="$OWNER" -F repo="$REPO" -F pr="$PR_NUMBER"
```

Filter to only unresolved threads (`isResolved == false`). These comments may come
from human reviewers or automated reviewers (GitHub Copilot, bots) — treat them
identically.

### General comments (conversation-level)

These are top-level comments on the PR, not attached to specific lines:

```bash
gh api "repos/$OWNER/$REPO/issues/$PR_NUMBER/comments" --jq '.[] | {id, body, user: .user.login, created_at}'
```

General comments often come from bots (Claude, Copilot) and may contain structured
reviews with multiple sections — issues, observations, suggestions. Parse these
carefully: a single comment might contain several independent actionable items
under different headings. Assess every item, including those labeled "non-blocking"
or "observations" — they may still be worth fixing.

Ignore purely conversational comments (approvals, thank-yous, status updates,
deployment previews).

### Short-circuit if there's nothing to do

If the unresolved-thread query returns zero rows and the general-comment scan surfaces nothing actionable, stop here. Tell the user the PR has no outstanding feedback and exit — don't press on into Step 3 just to be thorough, and don't invent work to fill the void.

## Step 3: Assess and triage

Go through each comment and decide whether it's actionable. For each comment,
consider:

- Is this a concrete suggestion or requested change?
- Does it point out an actual bug, oversight, or improvement?
- Or is it a stylistic preference, a question that's already answered, or something
  you disagree with?

**When you believe a comment is not worth addressing, ask the user for confirmation
before skipping it.** Present the comment and your reasoning — the user is the
final judge. For example:

> This comment suggests X. I don't think this needs addressing because Y.
> Should I skip it, or would you like me to fix it?

Only skip a comment after the user explicitly agrees.

## Step 4: Fix the code

Read the relevant files, understand the context, and make the fixes. For review
thread comments, the `path` and `line` fields tell you exactly where to look.
For general comments, you may need to identify the relevant code yourself.

## Step 5: Commit and push

Use your judgment on how to split commits:

- Minor, related fixes can go in one commit
- Substantial or logically separate changes warrant their own commits

Write clear commit messages. For general comment fixes, include the context of
what was addressed in the commit message since you won't be replying to those
comments.

Push after committing:

```bash
git push
```

## Step 6: Close the loop

### For review thread comments

Reply to each addressed comment, then resolve the thread. The reply should
include the short commit hash and can include brief context about the fix:

- `"Fixed in abc1234"` for straightforward fixes
- `"Fixed in abc1234 — switched to a native button for proper keyboard handling"` when a bit of context helps

**Reply** (use the REST API — simpler for replies):

```bash
gh api "repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies" \
  -f body="Fixed in $SHORT_HASH"
```

`$COMMENT_ID` must be the **REST API numeric ID** — the `databaseId` field from the first
comment of the thread in the Step 2 GraphQL response. Don't pass the GraphQL `id` (the opaque
`PRRT_kw…` node ID) here; those are for the resolve mutation below, not for REST replies. The
error you get from swapping them is cryptic, which is why this trips people up.

`$SHORT_HASH` is `$(git rev-parse --short HEAD)` for the commit that addressed the thread.

**Resolve the thread** (requires GraphQL):

```bash
gh api graphql -f query='
  mutation($threadId:ID!) {
    resolveReviewThread(input:{threadId:$threadId}) {
      thread { id isResolved }
    }
  }
' -F threadId="$THREAD_ID"
```

`$THREAD_ID` is the GraphQL `id` from Step 2 (the opaque `PRRT_kw…` node ID, not `databaseId`).

### For general comments

No reply needed — the commit message serves as the record.

## Ordering and hash reuse

- Process review threads before general comments. General comments frequently restate feedback that's already a line-level thread; doing threads first means you either catch the duplication or fix the underlying issue once and skip the general-comment restatement.
- When replying with a commit hash, use the 7-character short hash (`git rev-parse --short HEAD`).
- If multiple review threads are fixed in the same commit, reply to each with the same hash.

## Things not to do

- **Don't** silently skip a comment you think isn't worth addressing. Present it to the user with your reasoning and only skip on explicit agreement — the reviewer is not in the room and you don't get to overrule them unilaterally.
- **Don't** resolve a thread without a commit to back it up. Every resolve should cite a real hash. Resolving without a fix signals to the reviewer that their feedback was ignored.
- **Don't** reply using the GraphQL node `id` — see Step 6 for why. Replies use `databaseId`; only the resolve mutation takes the node ID.
- **Don't** force-push or rewrite history as part of this skill. This is a forward-merge workflow — new commits land on top. History rewriting belongs to a different skill.
- **Don't** re-fix a general comment that restates a review thread you already addressed. The record is the commit; the thread reply is the acknowledgment. Two replies to the same fix is noise.
