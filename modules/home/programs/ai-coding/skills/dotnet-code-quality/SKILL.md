---
name: dotnet-code-quality
description: "Use when: reviewing C# / .NET diffs or PRs. Encodes language-specific quality rules (SOLID, async, immutability, fail-fast, testability) framed as review findings. Layered under thermo-code-quality."
---

# .NET Code Quality Review

Apply this skill when reviewing C# / .NET changes. It is layered **under** `thermo-code-quality` — apply thermo first for structural and architectural findings, then use this skill for .NET-specific issues.

For the planning and implementation perspective on the same rules, see [`dotnet-dev-guidelines`](../dotnet-dev-guidelines/SKILL.md). The standards are the same; the framing differs.

## Review checklist

Flag a finding for each rule violated in the diff. Cite the rule by name.

### Structure & simplicity

- `method-size`: Methods over ~50 lines or with multiple responsibilities. Recommend extracting helpers or reframing the logic.
- `class-cohesion`: Classes mixing unrelated responsibilities. Recommend splitting.
- `deep-nesting`: Nested conditionals beyond 2-3 levels. Recommend guard clauses and early returns.
- `giant-switch`: Long switch/if chains over a discriminating value. Recommend strategy / polymorphism.
- `misused-partial`: `partial` used to split a regular class. Partials are **only** for incorporating code into auto-generated classes.
- `expression-body-opportunity`: Single-statement methods written with full block syntax — flag as a small readability nit.

### Readability & maintainability

- `magic-value`: Magic strings or numbers. Recommend constants or enums.
- `enum-extension-pattern`: String/value conversions that should be enum extensions instead of separate utility methods.
- `naming-clarity`: Names that require comments to be understood, non-domain-standard abbreviations, or methods that aren't verbs / classes that aren't nouns.
- `naming-conventions`: Violations of PascalCase (types/methods) or camelCase (params/locals).
- `underscore-in-name`: Underscores in identifiers — flag as a readability regression.
- `code-region`: `#region` blocks — these hide code and enable bloat. Recommend removal and decomposition.

### SOLID & dependencies

- `program-to-implementation`: Direct dependency on a concrete type where an abstraction should be used.
- `new-in-business-logic`: `new ConcreteDependency()` inside business logic instead of DI.
- `srp-violation`: Class has multiple reasons to change.
- `ocp-violation`: Adding new behavior required modifying existing code instead of extending.
- `lsp-violation`: Subclass weakens the contract of its base.
- `isp-violation`: Client forced to depend on members it does not use.
- `dip-violation`: High-level module depends on a low-level module directly. Push for abstraction + injection.

### Control flow & logic

- `unnecessary-else`: `else` after a guard clause / early return.
- `long-parameter-list`: More than 3-4 parameters. Recommend a record / DTO.
- `duplicate-code`: Repeated logic that should be a method or utility.
- `silent-failure`: Catch blocks that swallow errors, fallback branches that hide invariant violations, methods that return defaults to paper over failures. **This is a serious issue — flag aggressively.**
- `null-in-collection`: Method returns `null` instead of an empty collection.

### Testability & robustness

- `hidden-dependencies`: Class instantiates its own dependencies, making unit tests require integration.
- `unisolated-side-effects`: DB / file / network calls mixed into business logic rather than behind an abstraction.
- `missing-fail-fast`: Code that allows undefined or corrupted state to continue. Push for exception or result type at the boundary.
- `mutable-dto`: DTOs/models that should be immutable but use mutable setters. Recommend `record` or `init`-only.

### Functional style

- `imperative-where-expression-fits`: Long imperative blocks where an expression-returning form would be clearer.
- `unnecessary-mutability`: Mutable state that could be immutable.
- `impure-helper`: A helper that should be pure but takes hidden inputs (statics, DI services for trivial logic, etc.).

### Performance & scalability

- `stopwatch-for-benchmark`: `Stopwatch` used for performance measurement where the `Benchmark` package is the canonical tool.
- `valueTask-opportunity`: Hot async paths returning `Task` where `ValueTask` is justified.
- `premature-optimization`: Optimization without profiling evidence. Push back unless the hot path is clearly identified.
- `missing-disposal`: `using` / `await using` missing for `IDisposable` / `IAsyncDisposable`.
- `eager-materialization`: `.ToList()` / `.ToArray()` called when `IEnumerable<T>` would suffice.
- `lazy-opportunity`: Expensive initialization that should be `Lazy<T>`.

### Async

- `sequential-independent-awaits`: Independent awaits in sequence instead of `Task.WhenAll`.
- `missing-cancellation-token`: Async method without a `CancellationToken` parameter, especially in services / repositories / long-running operations.
- `missing-async-disposable`: Async resource cleanup using `IDisposable` instead of `IAsyncDisposable`.

### Logging

- `plain-text-log`: Plain string interpolation in logs instead of structured logging.

## Review priority

When reviewing a .NET diff, prioritize findings in this order:

1. Silent failures and fail-fast violations.
2. Hidden dependencies and untestable code.
3. SOLID violations that will compound (especially DIP / SRP).
4. Spaghetti / deep nesting / giant switches that are obvious refactor candidates.
5. Magic values, naming, and convention violations.
6. Performance smells with a concrete cost.
7. Minor readability / convention nits — only if the larger issues are absent.

## Tone

Be direct. Cite the rule by name when possible. Prefer one high-conviction finding over five nits.
