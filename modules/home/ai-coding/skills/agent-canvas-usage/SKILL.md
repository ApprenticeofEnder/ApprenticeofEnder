---
name: agent-canvas-usage
description: "Use when: presenting a plan, decision point, tradeoff, or review to the user for structured feedback. Explains how to use the /canvas slash command (Agent Canvas) instead of inline questions or markdown plans for any non-trivial back-and-forth."
---

# Using the Agent Canvas

**Agent Canvas** (https://github.com/contember/agent-canvas) is a Claude Code skill plugin that lets you emit a rich, interactive document the user can annotate inline, then send structured feedback back in a single click. It replaces clunky terminal markdown plans and the older `planReview` workflow.

Lighter touches — small focused changes, single bug fixes — don't need the canvas. Use judgment.

## When to use the canvas

Use `/canvas` for:

- **Plan presentation.** Any non-trivial implementation plan: surface the steps, decisions, and tradeoffs as a canvas document so the user can mark specific items for changes rather than copy-pasting feedback.
- **Decision points.** When multiple valid approaches exist and the user should choose: present each option with tradeoffs as separate annotatable sections.
- **Ambiguity resolution.** When the user prompt has multiple interpretations: lay them out side-by-side on the canvas.
- **Pre-implementation review.** Before a `broad-implementer` starts a multi-part change, surface the internal plan via canvas.
- **Critic findings.** When the critic returns a structured review, render the findings on the canvas so the user can accept / reject / discuss each one.

Do **not** use the canvas for:

- Simple yes/no questions — those are fine inline.
- Status updates or progress reports — those go inline.
- The final completed result presentation — that's a normal response.

## How to use it

Invoke the slash command in your response:

```
/canvas
```

The runtime opens a browser tab at `http://localhost:19400/s/<session-id>` and renders the JSX document you emit. The user annotates sections, clicks "send feedback," and their structured response comes back to you.

### Authoring the canvas

When the canvas opens, emit a JSX document that:

1. **Frames the decision.** Top-level header stating what the user is being asked to decide or review.
2. **Lays out options or steps as separate annotatable blocks.** Each block should be tightly scoped so the user can react to it in isolation. Don't put three decisions in one paragraph.
3. **Surfaces tradeoffs explicitly.** For each option, list the pros, cons, and any non-obvious implications. Don't bury the cost.
4. **Asks specific questions.** Vague "what do you think?" prompts produce vague feedback. "Should we use approach A or B?" or "Is the test plan in section 3 adequate?" produce actionable feedback.
5. **Highlights anything you're guessing about.** Mark assumptions explicitly so the user can correct them.

### After the user responds

- Read the structured feedback carefully. Treat per-section annotations as authoritative for that section.
- If the user accepted parts and rejected others, update only the rejected parts — don't re-litigate accepted ones.
- If the feedback opens new questions, you can issue another `/canvas` round.
- Once aligned, update `plan.md` to reflect the agreed plan and proceed.
