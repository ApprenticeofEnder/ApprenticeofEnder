# Confluence backend

Host-specific publishing for the wiki skill. This is the only file that knows about
Confluence; page-type templates stay host-neutral. The tools are the claude.ai Atlassian MCP
(`mcp__claude_ai_Atlassian__*`). Read/discovery tools are pre-approved; **write tools prompt
for permission** — that prompt is the publish gate, on top of the in-dialogue confirmation.

## Target resolution (run before creating)

1. `getAccessibleAtlassianResources` → `cloudId` for the site (UUID or `site.atlassian.net`).
   Required by every Confluence call.
2. `getConfluenceSpaces` (needs `cloudId`) → pick the `spaceId`. Filter by `keys` or `type`
   (`global`/`personal`) when the user names a space.
3. Optional parent: `getPagesInConfluenceSpace` (needs `cloudId`, `spaceId`) or
   `searchConfluenceUsingCql` (e.g. `cql: 'space="ENG" and title~"Onboarding"'`) → `parentId`.
4. **Present the chosen space + parent to the user and confirm before writing.**

## Create (draft)

`createConfluencePage` — required `cloudId`, `spaceId`, `body`.

| Param | Use |
| ----- | --- |
| `cloudId` | from step 1 |
| `spaceId` | from step 2 |
| `body` | the drafted content |
| `title` | page title |
| `contentFormat` | `markdown` or `html` — **use the value the template declares** (`adf` also accepted) |
| `status` | **`draft`** by default; `current` only if the user explicitly asks |
| `subtype` | **`"live"`** for working documents (Live Doc); omit for all other page types |
| `parentId` | from step 3, if nesting |

Return the draft URL from the response so the user can review and publish.

## Update (living docs + edits)

`updateConfluencePage` — required `cloudId`, `pageId`, `body`. Fetch current state first with
`getConfluencePage` (`cloudId`, `pageId`, `contentFormat`), then update. Always pass a short
`versionMessage` describing the change. `pageId` may be the tiny-link id from a `/wiki/x/<id>`
URL.

## HTML `data-type` cheatsheet (for the HTML page types)

`contentFormat: "html"`. Do **not** wrap in `<html>/<head>/<body>`. Follow ADF nesting (no
block elements inside inline elements; no headings inside table cells).

```html
<!-- status lozenge: green | red | yellow | blue | neutral | purple -->
<span data-type="status" data-color="green">On track</span>

<!-- decision list -->
<ul data-type="decision-list">
  <li data-type="decision-item" data-state="DECIDED">Ship behind a flag</li>
  <li data-type="decision-item" data-state="UNDECIDED">Rollout date</li>
</ul>

<!-- panel: info | warning | note | success | error -->
<div data-type="panel-warning"><p>Risk: depends on the partner API.</p></div>

<!-- task list -->
<ul data-type="task-list">
  <li data-type="task-item"><input type="checkbox"> Draft RFC</li>
</ul>

<!-- date, user mention, two-column layout -->
<time datetime="2026-07-15">15 Jul 2026</time>
<span data-type="mention" data-user-id="ACCOUNT_ID">@Name</span>
<section data-type="layout-two-equal">
  <div data-type="column">…</div><div data-type="column">…</div>
</section>
```

Markdown types (`contentFormat: "markdown"`) use plain markdown; task checkboxes are written
as `- [ ]` / `- [x]`.
