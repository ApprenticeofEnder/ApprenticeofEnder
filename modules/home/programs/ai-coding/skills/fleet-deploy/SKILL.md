---
name: fleet-deploy
description: "Use when orchestrating multi-agent software work — dispatching scoped, bounded tasks to worker subagents (callsigns) and monitoring them. Triggers on phrases like 'deploy the fleet', 'dispatch workers', 'run a fleet', 'orchestrate agents', 'launch a sortie', or any request to fan out parallel/serial sub-work across multiple callsigns."
---

# Fleet Deploy

You are the **Enterprise** — the lead thread. You dispatch **worker subagents** (callsigns)
via the native `Agent` tool, monitor them in real time, review their output, and keep them
on-track. Metaphor: the lead is the aircraft carrier managing a fleet of planes flying
sorties.

This skill encodes the operational doctrine. Read it once when starting fleet work, then
execute.

## Reference material

- Task brief template: `~/.agents/tasks/missive.md`
- Worker agent definitions (installed): `~/.claude/agents/*.md`

## 1. Plan the deck before launching

Before any `Agent` call:

1. Decompose the work into **single bounded tasks** (one task = one worker). No multi-task
   briefs.
2. Pick a **callsign per task** by tier (see table). Never default to opus.
3. Decide **parallel vs serial**: independent tasks → parallel background fleet; dependent
   tasks → serial foreground (or chain via `SendMessage`).
4. Identify the **no-touch list** for each worker so they don't collide.

### Callsigns by tier

| Tier   | Callsigns              | Use for                                                            |
| ------ | ---------------------- | ------------------------------------------------------------------ |
| opus   | trigger                | hardest / architectural / security-critical (auth, crypto)         |
| sonnet | count, wiseman, jaeger | moderate feature slices, types, scaffold, frontend/UI              |
| sonnet | skald, lanza           | **docs generation** — pair them for parallel doc work              |
| sonnet | huxian, tailor         | **test generation** — pair them for parallel test work             |
| haiku  | fencer, tabloid        | mechanical edits, boilerplate, renames, surgical format-preserving |

Within a tier the workers are interchangeable — use distinct callsigns to run in parallel.

## 2. Pre-launch checks (skip → wasted sorties)

Two failure modes cost the most time, and both are launch-config not task quality.

### 2a. Worktree base

`isolation="worktree"` branches from **`origin/<default-branch>`**, NOT your local HEAD.
Unpushed local commits are invisible to worktree planes — they get the stale remote tip.

Before launching a fleet that depends on prior work:

- Push (or merge a PR) so the base is on `origin`.
- Verify: `git ls-tree -r --name-only origin/main | grep -c <expected-path>`
- Symptom of a stale base: env-check reports `BASE MISSING`.

### 2b. Permission pairing (launch mode determines worker permissions)

A worker's ability to Write/Edit/Bash depends on **how it was launched**, not the agent def.

| Launch                                | Parallel?  | Write/Edit       | Bash (build/test)        |
| ------------------------------------- | ---------- | ---------------- | ------------------------ |
| foreground (omit `run_in_background`) | no, serial | inherits session | inherits session         |
| background + default perms            | yes        | DENIED           | DENIED                   |
| background + `acceptEdits`            | yes        | OK               | gated → lead must verify |
| background + `bypassPermissions`      | yes        | OK               | OK (local sandbox)       |

A detached background worker can't answer a permission prompt — anything not pre-authorized
by the session's mode is auto-denied. To fly a **parallel background fleet**, the session
must be in `acceptEdits` or `bypassPermissions`. Otherwise fly **serial foreground**.

### 2c. Foreground canary

Before fanning out the full deck, fly **one foreground sortie** to confirm base + perms
inherit correctly. Cheap, catches misconfig in seconds.

## 3. Write the brief

Every brief includes (pattern: `~/.agents/tasks/missive.md`):

1. **ENV-SANITY first line** — worker runs `pwd`, checks base contains expected files,
   probes Write + Bash. STOP and report `BASE MISSING` / `PERMISSION BLOCKED` if either
   fails.
2. **Read FIRST** (binding) — spec/design doc, files to import from, local setup notes.
3. **One bounded task** — deliver list (files + behavior), tests to write, constraints
   (no-touch list, no cloud unless authorized).
4. **Done criteria the worker must run and confirm green** — install, build, tests, lint.
   Worker must print test output and report deviations.

The brief's contents become the worker's `prompt` verbatim.

## 4. Dispatch

```
Agent(
  subagent_type     = "<callsign>",       # callsign chosen by tier
  description       = "<callsign>: <T-id> <one-line>",
  prompt            = <contents of task brief>,
  run_in_background = true,               # parallel + watchable; omit for blocking
  isolation         = "worktree",         # optional: isolated git worktree
  model             = "<override>",       # optional: override default tier
)
```

- Launch independent workers in **a single message with multiple `Agent` calls** to run
  concurrently.
- Continue an existing worker with full context via `SendMessage` (by agent id/name) — a
  fresh `Agent` call has NO memory of prior runs.

## 5. Monitor

- `TaskList` — all workers + status.
- `TaskGet` / `TaskOutput` — a specific worker's live output.
- `TaskStop` — kill a worker going off-track.

Background workers auto-notify on completion. **Do not poll**, do not insert sleeps.

## 6. Review and merge

When a worker completes:

1. Read its report.
2. If Bash was gated (background + `acceptEdits`), **re-run the done-criteria yourself**.
3. Verify the diff matches what was briefed — workers sometimes report success without it.
4. If `isolation="worktree"`, the branch path is in the result — merge or cherry-pick
   into the main worktree. Otherwise the changes are already in-tree.
5. If the worker hit a blocker, decide: re-dispatch with corrected brief, continue via
   `SendMessage` with new context, or escalate the tier.

## Rules

- **One bounded task per worker.** No multi-task briefs.
- **Pick tier by complexity.** Don't default to opus.
- **Lead reviews output** before declaring done — especially when Bash was gated.
- **Respect per-project constraints** (no cloud, local-only deploys, repo style).
- **Foreground canary** before any large parallel fleet.
- Worker defs live in `~/.claude/agents/`. Brief templates live in `~/.agents/tasks/`.
