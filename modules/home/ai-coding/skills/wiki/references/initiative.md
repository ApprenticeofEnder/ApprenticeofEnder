# Initiative template

A page that pitches and tracks a project or effort. **Publish format: HTML**
(`contentFormat: "html"`) — uses a status lozenge and risk panel. See
[confluence](confluence.md) for the `data-type` cheatsheet and publish calls.

Fill the sections below; drop any that don't apply. Keep the status lozenge current on edits.

```html
<h2>Summary</h2>
<p>One or two sentences: what this initiative is and the outcome it targets.</p>

<p><strong>Status:</strong>
  <span data-type="status" data-color="green">On track</span></p>

<h2>Driver &amp; stakeholders</h2>
<ul>
  <li><strong>Driver:</strong> <span data-type="mention" data-user-id="ACCOUNT_ID">@Name</span></li>
  <li><strong>Stakeholders:</strong> teams / people informed</li>
</ul>

<h2>Problem &amp; context</h2>
<p>Why this matters now; what happens if nothing changes.</p>

<h2>Goals &amp; success metrics</h2>
<ul>
  <li>Goal — measurable signal of success</li>
</ul>

<h2>Scope</h2>
<p><strong>In:</strong> …</p>
<p><strong>Out:</strong> …</p>

<h2>Milestones</h2>
<table>
  <tr><th>Milestone</th><th>Target</th><th>Owner</th></tr>
  <tr><td>…</td><td><time datetime="2026-07-15">15 Jul 2026</time></td><td>…</td></tr>
</table>

<h2>Risks</h2>
<div data-type="panel-warning"><p>Risk and mitigation.</p></div>

<h2>Links</h2>
<ul><li><a href="URL">Related ticket / doc</a></li></ul>
```
