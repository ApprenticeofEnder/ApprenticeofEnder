---
name: wiki
description: Use when the user asks to make or update a working document, wiki page, or other form of documentation to accompany a task. Drafts initiatives, investigations, guides, DACI decisions, and living working documents, then publishes them to Confluence.
---

# Wiki Skill

Drafts structured wiki pages from reusable templates and publishes them to a wiki host.
Page-type templates are host-agnostic content; the host backend (currently Confluence) is
isolated to one reference so other hosts can be added later. Depth lives in references loaded
on demand.

## Page types

| Type | Pick when | Format | Reference |
| ---- | --------- | ------ | --------- |
| **Initiative** | Pitching/tracking a project or effort: goals, scope, milestones, status | HTML | [initiative](references/initiative.md) |
| **Investigation** | Recording a debugging effort, RCA, or research dig: evidence → root cause → recommendation | Markdown | [investigation](references/investigation.md) |
| **Guide** | A how-to / runbook others will follow step by step | Markdown | [guide](references/guide.md) |
| **DACI** | Capturing a decision with roles (Driver/Approver/Contributors/Informed) and options weighed | HTML | [daci](references/daci.md) |
| **Working document** | A *Confluence Live Doc* that tracks an in-flight task/project — updated as work progresses; **never** a regular page | Markdown | [working-doc](references/working-doc.md) |

A **working document** is a Confluence **Live Doc** (`subtype: "live"`), not a regular page
and not a local file. It is created once and **updated** repeatedly as the task moves; treat
re-runs on the same task as updates.

## Workflow

1. **Pick the page type** from the table → load its reference for the section skeleton and
   declared content format.
2. **Draft the content** by filling the template's sections in its declared format (markdown
   or HTML). HTML types use Confluence-native elements — see
   [confluence](references/confluence.md) for the `data-type` cheatsheet.
3. **Resolve the target** (see [confluence](references/confluence.md) for the calls):
   discover accessible sites → spaces → optional parent page. **Present the candidate space +
   parent and confirm with the user before creating anything.**
4. **Publish as a draft.** Create the page with `status=draft` and the template's
   `contentFormat`. Return the draft URL so the user can review and publish in Confluence.
5. **Updates** (living working docs, or edits to any page): fetch the current page, then update
   it with a short `versionMessage` describing the change.

## Rules

- **Never publish without confirming the target** space/parent with the user.
- **Default to draft.** Do not create pages as `current` unless the user explicitly asks.
- **Match the format to the type.** Use the format the template declares — don't downgrade an
  HTML type to markdown (loses status lozenges, decision lists, panels).
- **Adding a new wiki host** = add one `references/<host>.md` backend file and route to it; the
  page-type templates do not change.
