# Host-agnostic wiki templates with a single Confluence backend

The `wiki` skill needs to publish to Confluence now but may target other wiki hosts later. We
keep the five page-type templates host-neutral and isolate all host-specific publishing
(MCP calls, content format, `data-type` elements) in `references/confluence.md`, rather than
building a speculative host-adapter abstraction up front. Adding a host later means adding one
`references/<host>.md` backend file and routing to it — the templates do not change. We chose
this over a full adapter contract because there is only one host today (YAGNI), and over
hard-coding Confluence throughout because that would force a rewrite when a second host arrives.
