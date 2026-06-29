# Working document template

A *living* page that tracks an in-flight task or project. Created once, then **updated** as
work progresses (see the update flow in [confluence](confluence.md)). **Publish format:
Markdown** (`contentFormat: "markdown"`).

On each update, append to the progress log and refresh **Status** + last-updated rather than
rewriting history. Use a short `versionMessage` per update.

```md
## Objective

What this task/project is trying to achieve.

## Status

`In progress` · last updated YYYY-MM-DD

## Plan / approach

The current intended approach. Revise as it changes.

## Progress log

- **YYYY-MM-DD** — what happened / what was done.

## Decisions made

- Decision — rationale (promote significant ones to a DACI page if needed).

## Open questions / blockers

- Question or blocker — who can unblock.

## Tasks

- [ ] Next step
- [x] Done step

## Links

PRs, tickets, related wiki pages.
```
