---
name: pr-review
description: Review a pull request, or respond to a pull request review.
---

## Workflow - Review

Use this ONLY when you are the reviewer.

1. Get context: diff changes against base branch and/or previous changes, and obtain user intent from description/comments
2. Run @critic and @tester to review the changes
3. Make individual comments at relevant locations in the diff based on the critic and tester results
4. Make a brief overview comment to summarize the review

## Workflow - Response

Use this ONLY when responding to code review comments.

1. Obtain relevant comment ID(s) using the GitHub CLI
2. Respond to those comments accordingly

## Commands

**IMPORTANT: These are PLACEHOLDERS, always substitute fields according to the task at hand.**

```bash
# Preamble, substitute variables based on PR context
OWNER="acresecurity"
REPO="example-repo"
PULL_NUMBER="13"
COMMENT_BODY="Great stuff!"
COMMIT_ID="6dcb09b5b57875f334f61aebed695e2e4193db5e" # the commit SHA
FILE_PATH="file1.txt"
COMMENT_ID="123456789" # id of existing review comment, replying to

# Adding general comments
gh pr comment "$PULL_NUMBER" -b "$COMMENT_BODY"

# Adding comments at specific locations
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$OWNER/$REPO/pulls/$PULL_NUMBER/comments" \
  -f body="$COMMENT_BODY" \
 -f commit_id="$COMMIT_ID" \
 -f path="$FILE_PATH" \
 -F start_line=1 \
 -f start_side='RIGHT' \
 -F line=2 \
 -f side='RIGHT'

# Get existing comments
gh pr view "$PULL_NUMBER" comments
gh api "/repos/$OWNER/$REPO/pulls/$PULL_NUMBER/comments" # if you need IDs

# Get comment IDs
gh api "/repos/$OWNER/$REPO/pulls/$PULL_NUMBER/comments" | jq '.[].id'

# Replying to specific existing comment (threaded reply, not new top-level comment)
# Get COMMENT_ID via: gh api "/repos/$OWNER/$REPO/pulls/$PULL_NUMBER/comments" | jq '.[].id'
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/$OWNER/$REPO/pulls/$PULL_NUMBER/comments/$COMMENT_ID/replies" \
  -f body="$COMMENT_BODY"

# Approving review
gh pr review "$PULL_NUMBER" --approve --body "$COMMENT_BODY"

# Commenting review
gh pr review "$PULL_NUMBER" --comment --body "$COMMENT_BODY"

# Change request review
gh pr review "$PULL_NUMBER" --request-changes --body "$COMMENT_BODY"
```

## Guardrails

- Prioritize correctness, security, and regressions over style-only comments.
- Comment as close to the location of the issue as possible.
- Keep all comments brief and human-readable.
- DO NOT add unnecessary context, fluff, or other overly verbose content.
- Comments with more than 500 characters MUST be reviewed by the operator prior to posting.
