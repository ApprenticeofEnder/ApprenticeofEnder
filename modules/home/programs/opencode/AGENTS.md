# General Rules

- Use modular, reusable code as much as possible.
- When doing feature development, move slow and start small. Get things working correctly before moving on.
- Use good security practices. Follow security principles well, and think about potential security implications with each change as relevant.

# Agent Instructions

**Strongly prefer using serena instead of other tools when multiple approaches are available. Check if onboarding has been performed, and if not, use a subagent to onboard with serena before proceeding.**

Make sure to update serena's knowledge base when you acquire new information that would be relevant for future tasks. Ensure that the information is accurate and well-organized to facilitate easy retrieval in future interactions.

# General Guidelines

## 1. Think Before Coding

**Don't assume or hide confusion. Surface tradeoffs as they appear.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them (don't pick silently).
- If a simpler approach exists, say so, and push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code or documentation:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Never Nesting

**Do not nest more than 3 layers deep except as an absolute last resort.**

When writing or modifying code:

- A "nesting layer" starts at either the class or function level (whichever is closest to the code in question).
- Ensure that you do not nest more than 3 layers deep.
- Use guard clauses to avoid nesting unnecessarily.
- If you nest more than 2 layers, ask yourself if the code can be extracted to a function.

The user should be able to look at your code and immediately discern what set of conditions are met/unmet at any given point in time in the logic. They should be able to do that _without_ having to untangle a complex web of nested branching statements and loops.

## 5. Modularity and Reusability

**If you find yourself writing the same thing with minor tweaks more than twice, you're very likely doing it wrong.**

When writing, modifying, or evaluating code:

- Look for similar patterns in multiple places.
- If you find yourself writing the same thing for multiple items, use a loop.
- If you write the same thing multiple times with different values, use a function.
- Use the principles of good software engineering.
- If you are unsure about whether a piece of code can/should be modularized, ask. Assume nothing.

Write your code so that a human can read it quickly, not just another agent.
