---
name: implement
description: Run through a series of subagents to implement a change cleanly.
disable-model-invocation: true
---

# Implement Workflow

Leverage subagents to implement a change incrementally for maximum code quality.

# Procedure

Run these in series, waiting for each agent to complete before moving onto the next.

1. Create a git worktree for the change.
2. Task a @drafter agent to create a rough implementation based on the plan.
3. Task a @simplifier agent to simplify the logic.
4. Task a @renamer agent to improve the naming.
5. Task a @tester agent to identify and resolve edge cases and failure points.
6. Task a @deduplicator agent to identify and resolve duplicate code and opportunities for consolidation.
7. Task a @critic agent to identify remaining issues and resolve them.

# Guardrails

1. In between each step of the workflow, commit your changes to version control. Use conventional commits.
