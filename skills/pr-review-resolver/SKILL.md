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
gh pr view --json number,url,headRefName
gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
```

If there's no PR on the current branch, ask the user for a PR number or URL.

Every later command references three identifiers — `OWNER`, `REPO`, `PR_NUMBER`. Two caveats on how you carry them:

- **Shell state doesn't persist between separate command runs.** A variable you set in one call is gone by the next, so the `$OWNER`/`$REPO`/`$PR_NUMBER` placeholders in the examples below are just that — substitute the literal values you read above into each command (or re-set the variables inside the same call). Don't assume an earlier assignment is still live.
- **If the user pasted a PR URL, read all three from the URL itself.** `gh repo view` reports the *current directory's* repo, which may not be where the PR lives (forks, monorepo splits, a URL for an unrelated repo). The URL is authoritative.

Then size the PR — Step 2 uses these counts to decide whether delegating is worth it. This gets both counts without pulling any comment bodies:

```bash
gh api graphql -f query='query($owner:String!,$repo:String!,$pr:Int!){repository(owner:$owner,name:$repo){pullRequest(number:$pr){reviewThreads{totalCount} comments{totalCount}}}}' -F owner="$OWNER" -F repo="$REPO" -F pr="$PR_NUMBER"
```

## Step 2: Fetch and distill outstanding comments (delegate to a cheap model)

The payloads are large and parsing them is low-judgment: automated reviewers
(Copilot, Claude, bots) bury a few actionable points under markdown chrome —
collapsible sections, status tables, emoji headers, deploy-preview noise. So
**delegate the fetch to a Sonnet subagent**: the raw output never lands in your
context, and you get back a distilled worklist and spend your own context on the
assessment and fixes (Steps 3+) that *do* need the session model's judgment.

Spawn **one** subagent with the `Agent` tool (`subagent_type: general-purpose`,
`model: sonnet`). Pin the model explicitly — with no `model`, the subagent
inherits your session model rather than Sonnet. Its context is isolated (it sees
nothing of this conversation), so the brief must carry the literal `OWNER`,
`REPO`, and `PR_NUMBER` values from Step 1, the two commands below, and the rules
that follow.

> **Skip delegation for a tiny PR.** If the counts from Step 1 are small (say,
> under ~5 threads and comments combined), just run the two commands yourself —
> spawning a subagent isn't worth the overhead. The delegation pays off when
> there are many threads or verbose bot reviews.

The subagent runs two commands. **Review threads** (GraphQL — the only way to get
resolution status and thread IDs):

```bash
gh api graphql -f query='
  query($owner:String!, $repo:String!, $pr:Int!) {
    repository(owner:$owner, name:$repo) {
      pullRequest(number:$pr) {
        reviewThreads(first:100) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            isOutdated
            path
            line
            comments(first:50) {
              nodes {
                databaseId
                body
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -F owner="$OWNER" -F repo="$REPO" -F pr="$PR_NUMBER"
```

**General comments** (REST — top-level, not attached to lines):

```bash
gh api "repos/$OWNER/$REPO/issues/$PR_NUMBER/comments" --jq '.[] | {id, body, user: .user.login}'
```

Rules for the subagent's brief:

- **Review threads:** keep only `isResolved == false`. Human and automated
  reviewers are treated identically. For each surviving thread return the thread's
  GraphQL node `id` (starts `PRRT_`), the `databaseId` of the thread's **first**
  comment (an integer, used for REST replies later), `path`, `line`, `isOutdated`,
  author login, and a chrome-free distillation of the **whole thread's**
  conversation (not just the first comment — later replies may narrow, widen, or
  withdraw the original point).
- **General comments:** drop purely conversational ones (approvals, thank-yous,
  CI/deploy previews, status updates). A structured bot review may pack several
  independent points under different headings — split it into discrete actionable
  items, one entry per point, and include items labeled "non-blocking", "nit", or
  "observation" (they may still be worth fixing). Preserve the parent comment's
  numeric `id` (needed later to reference the comment when declining).
- **Distill, don't dump.** Strip boilerplate, collapsible wrappers, emoji headers,
  and status tables, but keep the technical substance faithfully enough to be
  assessed on its own. Never paste whole files or diffs.
- **IDs are load-bearing — copy them exactly.** Never paraphrase, reformat, or
  "tidy up" a node `id` or `databaseId`; a single altered character breaks the
  reply and resolve steps. Use `null` for a field that's genuinely absent.
- **Paginate if truncated.** If the review-threads query returns
  `pageInfo.hasNextPage == true`, request the next page with `endCursor` and merge
  — never stop at the first 100. (A thread with >50 comments is vanishingly rare;
  don't bother paginating within a thread.)
- **Never fabricate a worklist.** If either command fails (auth, network, wrong
  repo), return its error output verbatim as the result — do not return an empty
  or invented worklist. An empty list means "genuinely nothing unresolved," and
  the next step trusts it.

Tell the subagent its final message must be **exactly** this JSON object and
nothing else — no prose, no code fences:

```
{
  reviewThreads: [
    { threadId, firstCommentDatabaseId, path, line, isOutdated, author, body }
  ],
  generalComments: [
    { commentId, author, items: [ { summary, detail } ] }
  ]
}
```

(The `Agent` tool has no schema enforcement, so that instruction plus the check
below are what keep the output honest.) When it returns, sanity-check the shape:
`threadId`s should start `PRRT_` and `firstCommentDatabaseId` should be an
integer. If the subagent returned an error, prose instead of the structure, or
malformed IDs, re-run the fetch rather than proceeding on guesswork — everything
downstream depends on these identifiers.

### Short-circuit if there's nothing to do

If the worklist comes back with no unresolved threads and nothing actionable in
the general comments, stop here. Tell the user the PR has no outstanding feedback
and exit — don't press on into Step 3 just to be thorough, and don't invent work
to fill the void.

## Step 3: Assess and triage — one pass, one table

Engage with each item critically. Your job is to form a real opinion about
whether the reviewer is right — not to default to agreement. Reviewers miss
context, push stylistic preferences, suggest premature abstractions, raise
out-of-scope concerns, and sometimes just get things wrong. The goal of code
review is better code, not every comment satisfied.

For each item in the worklist, ask:

- Is the reviewer correct about the problem? Did they misread the code?
- Would the suggested change actually improve things, or make them worse
  (more abstract, more verbose, more coupled, harder to follow)?
- Is it in scope for this PR, or a separate concern that belongs elsewhere?
- Is it a stylistic preference that conflicts with the codebase's conventions?
- Does the reviewer have context you don't — a constraint, downstream impact,
  or domain knowledge that makes the comment land harder than it looks?

Assign each item one of three dispositions:

- **Fix** — you agree; you'll change the code.
- **Decline** — you disagree (wrong, out of scope, low-value, or a stylistic
  preference against the codebase's conventions). Draft the justification now —
  the concrete reasoning you'd post to the reviewer, not a vague "won't do."
- **Ask** — a genuine product or preference call you shouldn't make alone.

### Present the whole slate at once, then let the user respond by exception

Don't stop and ask on each item one at a time. Assess everything first, then
present a single triage table so the user sees the shape of the whole review in
one place:

| # | Source | Summary | Proposed | Why |
|---|--------|---------|----------|-----|
| 1 | `foo.ts:42` | use a native button | **Fix** | agree, keyboard a11y |
| 2 | `bar.ts:88` | extract a shared helper | **Decline** | premature abstraction, single caller |
| 3 | general (Copilot) | reword the user-facing error copy | **Ask** | product wording, your call |

Below the table, for each **Decline** row show the full reply text you'd post to
the reviewer — the actual words, not the terse "Why" summary. By-exception
approval has to cover what actually goes out under the user's name, and the
table cell is too small to carry it.

Then tell the user to respond **by exception**: they override only the rows they
disagree with, and any **Fix** or **Decline** row they don't mention stands as
proposed. This is one decision point instead of one per comment; showing the
Fixes in the table is what lets them catch "actually, leave #1 alone" *before*
you touch the code. **Ask rows are the exception** — they have no proposed
disposition to stand, so they always need an explicit answer. If the user's
response doesn't resolve an Ask, re-ask before moving on.

The user is the final judge — you're proposing the slate, not deciding it.

Once the user has responded, lock in the dispositions. Keep, for each Decline,
the full reply text; and for each Ask, its resolved Fix/Decline. If while fixing
you discover a disposition was wrong — the comment was right after all, or the
"fix" turns out to be a bad idea — surface that to the user rather than silently
flipping it.

## Step 4: Fix the code

If every comment was declined in Step 3, there's nothing to fix and nothing to
commit — skip Steps 4 and 5 and go directly to Step 6 to post the
justifications.

Read the relevant files, understand the context, and make the fixes. For review
thread comments, the `path` and `line` fields tell you where to look. When `line`
is null or `isOutdated` is true, the code moved since the comment was written —
locate it from `path` and the comment text. If the concern no longer applies to
the current code, that's a Decline-with-explanation ("this was addressed when the
code changed in X"), not a silent skip. For general comments, you may need to
identify the relevant code yourself.

## Step 5: Commit and push

Use your judgment on how to split commits:

- Minor, related fixes can go in one commit
- Substantial or logically separate changes warrant their own commits

Write clear commit messages. For general comment fixes, include the context of
what was addressed in the commit message since you won't be replying to those
comments.

**As you commit, record which worklist items each commit covers and capture its
short hash right then** — `git rev-parse --short HEAD` immediately after the
commit. If you split into several commits, `HEAD` only points at the last one, so
a hash captured later would mislabel every earlier fix. You need a
{item → commit hash} map for Step 6, not a single `HEAD` read at the end.

Push after committing:

```bash
git push
```

If the push fails (protected branch, diverged upstream, auth), stop and surface
it — don't proceed to Step 6. A reply citing a hash reviewers can't pull, or a
resolved thread with no visible commit, is worse than no reply.

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

`$COMMENT_ID` must be the **REST API numeric ID** — the `firstCommentDatabaseId` from the
Step 2 worklist. Don't pass the GraphQL `threadId` (the opaque `PRRT_kw…` node ID) here; that's
for the resolve mutation below, not for REST replies. The error you get from swapping them is
cryptic, which is why this trips people up.

`$SHORT_HASH` is the hash you recorded for **the commit that addressed this
thread** — from the {item → commit hash} map you built in Step 5, not a fresh
`git rev-parse HEAD` (which points only at the last commit). If one thread was
fixed across several commits, cite the last of them.

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

`$THREAD_ID` is the `threadId` from the Step 2 worklist (the opaque `PRRT_kw…` node ID, not `firstCommentDatabaseId`).

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

`$COMMENT_ID` follows the same convention as the fix-reply path above — the
`firstCommentDatabaseId` from the Step 2 worklist, not the GraphQL `threadId`.

Don't run the `resolveReviewThread` mutation. Don't include a commit hash —
there's no commit to cite, and the reply should read as a position, not a
fix announcement.

For general comments (which have no thread reply mechanism), post the
justification as a top-level PR comment:

```bash
gh api "repos/$OWNER/$REPO/issues/$PR_NUMBER/comments" \
  -f body="$JUSTIFICATION"
```

A top-level comment is detached from what it answers, so open the justification
by naming the item it addresses — quote the reviewer's phrasing or the point,
not just "re: your comment." If that comment was a multi-item bot review where
you fixed some items and declined others, note the fixed ones too ("items 1 and
3 addressed in abc1234; on item 2: …") so the reviewer gets one coherent reply
rather than a response that looks partial.

The justification text should be the reasoning you and the user agreed on in
Step 3 — phrased for the reviewer, not paraphrased into something vaguer.

## Ordering and hash reuse

- Process review threads before general comments. General comments frequently restate feedback that's already a line-level thread; doing threads first means you either catch the duplication or fix the underlying issue once and skip the general-comment restatement.
- Cite the short hash from the Step 5 {item → commit} map — the commit that actually contains each fix, not whatever `HEAD` happens to be at reply time.
- If multiple review threads were fixed in one commit, reply to each with that same hash.

## Things not to do

- **Don't** silently skip a comment you think isn't worth addressing. Surface it in the Step 3 triage table with your reasoning and the reply text, and let the user sign off on the slate before you post — they can veto any row (silence on a row they saw is agreement; a decline you never showed them is not). Then post that justification as a reply so the reviewer sees it — they're not in the room and you don't get to overrule them unilaterally.
- **Don't** capitulate to a comment you don't believe in just to make it go away. Quietly fixing a comment you think is wrong is the inverse failure of silently declining — it pollutes the codebase to satisfy a single review. If you disagree, say so concretely and let the user decide.
- **Don't** resolve a thread without a commit to back it up. Every resolve should cite a real hash. In particular, don't resolve a thread you declined — the reviewer raised it and gets to decide whether your justification settles things. Resolving on their behalf signals you're treating the conversation as one-sided.
- **Don't** reply using the GraphQL node `id` — see Step 6 for why. Replies use `databaseId`; only the resolve mutation takes the node ID.
- **Don't** force-push or rewrite history as part of this skill. This is a forward-merge workflow — new commits land on top. History rewriting belongs to a different skill.
- **Don't** re-fix a general comment that restates a review thread you already addressed. The record is the commit; the thread reply is the acknowledgment. Two replies to the same fix is noise.
