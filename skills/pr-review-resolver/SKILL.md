---
name: pr-review-resolver
description: Address outstanding review comments on a GitHub pull request. Fetches all unresolved review threads and general PR comments, assesses each for validity, then either fixes the code, commits, replies with the commit hash, and resolves the thread, or — when declining — replies with justification and leaves the thread for the reviewer to resolve. Use this skill whenever the user wants to address, fix, resolve, or work through PR review comments or feedback — even if they just say something like "handle the PR comments", "address the review feedback", "fix what the reviewers said", or "go through the PR". Also trigger when the user pastes a PR URL and asks you to act on the feedback there.
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

Engage with each comment critically. Your job is to form a real opinion about
whether the reviewer is right — not to default to agreement. Reviewers miss
context, push stylistic preferences, suggest premature abstractions, raise
out-of-scope concerns, and sometimes just get things wrong. The goal of code
review is better code, not every comment satisfied.

For each comment, ask:

- Is the reviewer correct about the problem? Did they misread the code?
- Would the suggested change actually improve things, or make them worse
  (more abstract, more verbose, more coupled, harder to follow)?
- Is it in scope for this PR, or a separate concern that belongs elsewhere?
- Is it a stylistic preference that conflicts with the codebase's conventions?
- Does the reviewer have context you don't — a constraint, downstream impact,
  or domain knowledge that makes the comment land harder than it looks?

If you disagree, say so concretely. "I don't think this is worth addressing
because X" is a real position; silently fixing a comment you don't believe in
is capitulation, not collaboration.

**When you decide a comment isn't worth addressing — whether because it's
wrong, out of scope, low-value, or stylistic — present it to the user with
your reasoning before declining.** The user is the final judge.

> This comment suggests X. I don't think this needs addressing because Y.
> Should I decline it, or would you like me to fix it?

Only decline after explicit user agreement. Declining isn't silent: in Step 6
you'll post the justification as a reply on the PR and leave the thread
unresolved so the reviewer can accept the reasoning or push back. Track which
comments are being declined and the justification text agreed on with the
user — you'll need both when posting the replies.

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

### For declined comments

When the user agreed to decline a comment, post the justification as a reply
but leave the thread unresolved. The reviewer raised it and gets to decide
whether the rationale settles the matter, wants to push back, or wants to
discuss further — resolving on their behalf preempts that conversation.

For review threads, reply via the same REST endpoint used for fix replies,
but with the justification text instead of a commit hash:

```bash
gh api "repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies" \
  -f body="$JUSTIFICATION"
```

Don't run the `resolveReviewThread` mutation. Don't include a commit hash —
there's no commit to cite, and the reply should read as a position, not a
fix announcement.

For general comments (which have no thread reply mechanism), post the
justification as a top-level PR comment so the reviewer sees it in context:

```bash
gh api "repos/$OWNER/$REPO/issues/$PR_NUMBER/comments" \
  -f body="$JUSTIFICATION"
```

The justification text should be the reasoning you and the user agreed on in
Step 3 — phrased for the reviewer, not paraphrased into something vaguer.

## Ordering and hash reuse

- Process review threads before general comments. General comments frequently restate feedback that's already a line-level thread; doing threads first means you either catch the duplication or fix the underlying issue once and skip the general-comment restatement.
- When replying with a commit hash, use the 7-character short hash (`git rev-parse --short HEAD`).
- If multiple review threads are fixed in the same commit, reply to each with the same hash.

## Things not to do

- **Don't** silently skip a comment you think isn't worth addressing. Present it to the user with your reasoning, only decline on explicit agreement, and post that justification as a reply so the reviewer sees it — they're not in the room and you don't get to overrule them unilaterally.
- **Don't** capitulate to a comment you don't believe in just to make it go away. Quietly fixing a comment you think is wrong is the inverse failure of silently declining — it pollutes the codebase to satisfy a single review. If you disagree, say so concretely and let the user decide.
- **Don't** resolve a thread without a commit to back it up. Every resolve should cite a real hash. In particular, don't resolve a thread you declined — the reviewer raised it and gets to decide whether your justification settles things. Resolving on their behalf signals you're treating the conversation as one-sided.
- **Don't** reply using the GraphQL node `id` — see Step 6 for why. Replies use `databaseId`; only the resolve mutation takes the node ID.
- **Don't** force-push or rewrite history as part of this skill. This is a forward-merge workflow — new commits land on top. History rewriting belongs to a different skill.
- **Don't** re-fix a general comment that restates a review thread you already addressed. The record is the commit; the thread reply is the acknowledgment. Two replies to the same fix is noise.
