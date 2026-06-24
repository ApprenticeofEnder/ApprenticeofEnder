# Fleet Manager — agent orchestration

Project-agnostic, language-agnostic. A **lead** thread (the main Claude Code agent — call it
the **Enterprise**) dispatches scoped, bounded tasks to callsign-named **worker subagents** via
the native `Agent` tool, monitors them live, reviews their output, and keeps them on-track.

Workers run as native Claude Code subagents. Background subagents are watchable in real time, and
the lead monitors them with `TaskList` / `TaskGet` / `TaskOutput` and is auto-notified on
completion.

Metaphor: the lead is the aircraft carrier (**Enterprise**) managing a fleet of planes (agents)
flying sorties (tasks).

## Install

Agent definitions must live in `~/.claude/agents/` to be loaded by Claude Code. Copy them there:

```
cp agents/*.md ~/.claude/agents/
```

Keep task briefs wherever you like (this repo's `tasks/`, or per-project). The lead passes a
brief's contents as the worker's prompt.

## Workers (callsigns, by model tier)

Most workers are distinguished only by **tier** — the **task brief supplies the domain** — and
within a tier are interchangeable (use distinct ones to run work in parallel). A few callsigns
carry a **domain specialization** baked into their prompt (docs, tests); prefer those for their
domain. Add more names by copying an agent file and renaming.

| Callsign  | Model  | Use for                                                                 |
| --------- | ------ | ----------------------------------------------------------------------- |
| trigger   | opus   | hardest / architectural / security-critical (auth, crypto)              |
| count     | sonnet | moderate (domain types, schemas, module logic, feature slices)          |
| wiseman   | sonnet | moderate (scaffold, toolchain/config, feature slices)                   |
| jaeger    | sonnet | moderate (frontend/UI slices, feature work)                             |
| skald     | sonnet | **docs generation** (READMEs, API/reference, guides) — pairs w/ lanza   |
| lanza     | sonnet | **docs generation** (READMEs, API/reference, guides) — pairs w/ skald   |
| huxian    | sonnet | **test generation** (unit/integration/edge cases) — pairs w/ tailor     |
| tailor    | sonnet | **test generation** (unit/integration/edge cases) — pairs w/ huxian     |
| fencer    | haiku  | mechanical (boilerplate, config, renames, format-preserving)            |
| tabloid   | haiku  | **precision edits** (surgical, format-preserving) — pairs w/ fencer     |

## Dispatch a worker

The lead uses the `Agent` tool. The task brief is the worker's prompt — pass the contents of a
brief file (e.g. one based on `tasks/TEMPLATE.md`) or an inline brief.

```
Agent(
  subagent_type    = "trigger",                  # callsign = tier
  description       = "trigger: T-030 authorizer",
  prompt           = <contents of the task brief>,
  run_in_background = true,                       # parallel + watchable; omit for blocking
  isolation         = "worktree",                 # optional: isolated git worktree
)
```

- `model` can be overridden per dispatch if a callsign's default tier doesn't fit the task.
- Launch independent workers in a single message (multiple `Agent` calls) to run concurrently.
- Continue an existing worker with full context via `SendMessage` (by agent id/name) instead of
  starting a fresh `Agent` call.

## Monitor

- **Human:** watch background workers live.
- **Lead:** `TaskList` (all workers + status) → `TaskGet` / `TaskOutput` (a worker's live output)
  → `TaskStop` if one goes off-track. Background workers auto-notify the lead on completion — no
  polling needed.

## Worktree base & permission pairing (operational doctrine)

Two common failure modes are launch-config, not task quality. Always open a brief with an
**env-sanity line** (pwd, base check, Write/Bash probe → STOP and report `BASE MISSING` /
`PERMISSION BLOCKED`) so a misconfig surfaces in seconds, not minutes.

### Worktree base

- `isolation="worktree"` branches the plane's worktree from **`origin/<default-branch>`** (the
  pushed remote ref), **not** your local `main`/HEAD. Unpushed local commits are invisible to
  worktree planes — they get the stale remote tip.
- Before launching a fleet that depends on prior work, **get the base onto origin** (push, or
  merge a PR) so worktrees branch from it. Verify the expected files are present at the remote
  tip, e.g. `git ls-tree -r --name-only origin/main | grep -c <expected-path>`.
- Symptom of a stale base: a plane's env-check reports `BASE MISSING` or sees only baseline files.

### Permission pairing (foreground vs background)

A plane's ability to Write/Edit/Bash depends on **how it was launched**, not the agent def:

| Launch                                    | Parallel?           | Write/Edit       | Bash (build/test)        | Use when                                       |
| ----------------------------------------- | ------------------- | ---------------- | ------------------------ | ---------------------------------------------- |
| **foreground** (omit `run_in_background`) | no — serial, blocks | inherits session | inherits session         | canary; or when session is NOT elevated        |
| **background** + default perms            | yes                 | ❌ DENIED        | ❌ DENIED                | broken — plane can only author into its report |
| **background** + `acceptEdits`            | yes                 | ✅               | ❌ gated → lead verifies | medium-risk parallel                           |
| **background** + `bypassPermissions`      | yes                 | ✅               | ✅ (local sandbox)       | full autonomous fleet, no-cloud posture        |

- **Why:** a detached background plane cannot answer a permission prompt, so anything not
  pre-authorized by the session's permission mode is auto-denied.
- **Rule:** to fly a **parallel background fleet**, put the session in an elevated mode
  (`acceptEdits` or `bypassPermissions`). Otherwise run sorties **foreground/serial** — proven to
  inherit the session's Write+Bash.
- A **foreground canary** (one blocking sortie) is the cheap way to confirm base+perms before
  fanning out the deck.

## Task briefs

A good brief states: the callsign + tier, the single task and its boundaries, files to read
first, explicit constraints (no-touch list, no cloud/deploys), and **done criteria the worker
must run and confirm**. See `tasks/TEMPLATE.md` for the pattern.

## Rules

- **Model-by-tier** — pick the callsign whose tier matches task complexity; never default
  everything to opus.
- **One bounded task per worker.** The lead reviews output (and re-runs done-criteria when the
  worker's bash was gated) before merging.
- Respect per-project deploy/policy constraints (e.g. no cloud deploys → local only).
- Worker agent definitions live in `~/.claude/agents/`. Keep task briefs in `tasks/` (or per
  project).
