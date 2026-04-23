---
name: pr-review-resolver
description: |
  Address outstanding review comments on a GitHub pull request. Fetches all
  unresolved review threads and general PR comments, assesses each for validity,
  fixes the code, commits, replies with the commit hash, and resolves threads.
  Use this skill whenever the user wants to address, fix, resolve, or work through
  PR review comments or feedback — even if they just say something like "handle the
  PR comments", "address the review feedback", "fix what the reviewers said", or
  "go through the PR". Also trigger when the user pastes a PR URL and asks you to
  act on the feedback there.
---

# PR Review Resolver

You address outstanding review feedback on a GitHub pull request: assess each
comment, fix the code, commit, and close the loop with reviewers.

## Prerequisites

- `gh` CLI authenticated and available
- Current branch has an open PR (or the user provides a PR number/URL)

## Step 1: Identify the PR

Try to detect the PR from the current branch:

```bash
gh pr view --json number,url,headRefName --jq '{number,url,headRefName}'
```

If there's no PR on the current branch, ask the user for a PR number or URL.

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
' -F owner="{owner}" -F repo="{repo}" -F pr="{pr_number}"
```

Filter to only unresolved threads (`isResolved == false`). These comments may come
from human reviewers or automated reviewers (GitHub Copilot, bots) — treat them
identically.

### General comments (conversation-level)

These are top-level comments on the PR, not attached to specific lines:

```bash
gh api repos/{owner}/{repo}/issues/{pr_number}/comments --jq '.[] | {id, body, user: .user.login, created_at}'
```

General comments often come from bots (Claude, Copilot) and may contain structured
reviews with multiple sections — issues, observations, suggestions. Parse these
carefully: a single comment might contain several independent actionable items
under different headings. Assess every item, including those labeled "non-blocking"
or "observations" — they may still be worth fixing.

Ignore purely conversational comments (approvals, thank-yous, status updates,
deployment previews).

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
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="Fixed in {short_hash}"
```

The `comment_id` here is the **REST API numeric ID**, which is the `databaseId`
field from the GraphQL query on the first comment in the thread. Don't confuse
this with the GraphQL `id` (opaque node IDs like `PRRT_kw...`) — those are for
the resolve mutation, not REST replies.

**Resolve the thread** (requires GraphQL):

```bash
gh api graphql -f query='
  mutation($threadId:ID!) {
    resolveReviewThread(input:{threadId:$threadId}) {
      thread { id isResolved }
    }
  }
' -F threadId="{thread_id}"
```

### For general comments

No reply needed — the commit message serves as the record.

## Notes

- Process review threads before general comments to avoid duplicate fixes when
  both mention the same issue.
- If a general comment overlaps with a review thread you already fixed, skip it.
- When replying with a commit hash, use the 7-character short hash (`git rev-parse
  --short HEAD`).
- If multiple review threads are fixed in the same commit, reply to each with the
  same hash.
