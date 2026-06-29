# DACI template

A decision record using the DACI framework (Driver, Approver, Contributors, Informed).
**Publish format: HTML** (`contentFormat: "html"`) — uses a status lozenge and a decision
list. See [confluence](confluence.md) for the `data-type` cheatsheet and publish calls.

Set the summary lozenge to `data-color="neutral"` while undecided, `green` once decided.

```html
<h2>Decision</h2>
<p><strong>Status:</strong>
  <span data-type="status" data-color="neutral">Undecided</span></p>
<p>One-line statement of the decision to be made.</p>

<h2>Roles</h2>
<table>
  <tr><th>Role</th><th>Who</th></tr>
  <tr><td>Driver</td><td><span data-type="mention" data-user-id="ACCOUNT_ID">@Name</span></td></tr>
  <tr><td>Approver</td><td>@Name</td></tr>
  <tr><td>Contributors</td><td>@Name, @Name</td></tr>
  <tr><td>Informed</td><td>team / channel</td></tr>
</table>

<h2>Background</h2>
<p>Context the reader needs to understand the decision.</p>

<h2>Options considered</h2>
<table>
  <tr><th>Option</th><th>Pros</th><th>Cons</th></tr>
  <tr><td>A</td><td>…</td><td>…</td></tr>
  <tr><td>B</td><td>…</td><td>…</td></tr>
</table>

<h2>Outcome</h2>
<ul data-type="decision-list">
  <li data-type="decision-item" data-state="UNDECIDED">The decision, once made</li>
</ul>

<h2>Action items</h2>
<ul data-type="task-list">
  <li data-type="task-item"><input type="checkbox"> Owner — follow-up</li>
</ul>

<h2>Deadline</h2>
<p><time datetime="2026-07-15">15 Jul 2026</time></p>
```
