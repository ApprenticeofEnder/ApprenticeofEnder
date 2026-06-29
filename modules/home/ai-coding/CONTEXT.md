# Wiki Authoring

The shared language of the `wiki` skill, which drafts structured pages from templates and
publishes them to a wiki host (currently Confluence). Defines the page types and the publish
vocabulary so the terms stay distinct.

## Language

### Page types

**Initiative**:
A page that pitches and tracks a project or effort — goals, scope, milestones, status.

**Investigation**:
A record of how a conclusion was reached — evidence, root cause, recommendation.
_Avoid_: postmortem, report (use when the focus is the dig, not the incident ritual)

**Guide**:
A how-to or runbook the reader follows step by step.
_Avoid_: tutorial, doc

**DACI**:
A decision record naming a Driver, Approver, Contributors, and Informed, with options weighed.

**Working Document**:
A *living* wiki page that tracks an in-flight task or project, updated as work progresses.
_Avoid_: scratchpad, notes, working file (it is not a local file)

### Publishing

**Host**:
The wiki system a page is published to. Confluence is the only host today; templates are
host-neutral so others can be added.

**Draft**:
A page created but not live; the default state for skill-authored pages, reviewed before going live.
_Avoid_: unpublished, WIP

**Publish**:
Making a page live on the host (status `current`) — a human action, not the skill's default.

## Relationships

- A **Working Document** may graduate findings into an **Initiative**, **Investigation**, or
  **Guide**, and may spin a **DACI** off a decision it records.
- Every page type publishes to one **Host** and is created as a **Draft** first.

## Example dialogue

> **Dev:** "I'll keep a working document for this migration."
> **Domain expert:** "A *living wiki page*, not a file in the repo — created once and updated
> as you go. When the approach is locked, capture that as a **DACI**, and the final how-to as a
> **Guide**."

## Flagged ambiguities

- "working document" was ambiguous between a local repo file and a wiki page — resolved: it is
  a living **Working Document** page on the **Host**, not a local file.
- "publish" was used for both creating a draft and making a page live — resolved: the skill
  creates **Drafts**; **Publish** is the human action of going live.
