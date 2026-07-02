## Rules Index

- [block-ordering-and-structure](./block-ordering-and-structure.md): Assess for overall block structure, variable definitions, etc.
- [count-vs-for-each](./count-vs-for-each.md): Assess the usage of count vs for_each.
- [modern-terraform-features](./modern-features.md): Assess the usage of post 1.0 Terraform features.
- [version-management](./version-management.md): Assess version management.
- [refactoring-patterns](./refactoring-patterns.md): Assess version upgrades and secrets remediation.
- [locals](./locals.md): Assess the adherence to using locals for dependency management.

## LLM Mistake Checklist — Code Patterns

Common model mistakes when generating HCL. Correct these before returning code:

- defaults to `count` for every collection — prefer `for_each` with stable keys whenever identity matters
- omits `moved` blocks during rename/refactor, silently turning the change into destroy/create
- builds `for_each` keys from computed IDs not known until apply — planning will fail
- uses list index as long-lived identity (`count.index`) instead of business-meaningful keys
- marks variables `sensitive = true` and assumes the value stays out of state — on 1.11+ use `write_only` / `*_wo` arguments
- falls back to `element(concat(...))` instead of `try()` on 0.12.20+
- accepts untyped `map(any)` / `any` for long-lived module contracts instead of `optional()` with typed defaults (1.3+)
- suggests `terraform state mv` where `moved` blocks are safer and reviewable
- recommends ad-hoc CLI `terraform import` instead of declarative `import` blocks (1.5+)
- emits an exact `version = "5.0.0"` pin where `~> 5.0` would be more maintainable
- silently emits 1.11+ features (S3 native lock, `write_only`, `removed`) without checking the runtime floor
- uses `nonsensitive()` to "fix" a sensitive value appearing in plan output — this leaks secrets into CI artifacts
- conflates `sensitive = true` with `ephemeral` (1.10+); only `ephemeral` actually stays out of state
- writes a `moved` block expecting it to cross provider boundaries; it cannot
- leaves `moved` blocks inside a module that itself is being removed — the moves silently no-op, resources get destroyed
- emits CLI `terraform import` in automation when declarative `import` blocks (1.5+) give a reviewable, VCS-tracked alternative
- emits `ignore_changes = all` or broad ignore lists to silence plan output instead of diagnosing drift root cause
- uses `check` block expecting it to block apply; `check` is advisory, emits warnings only. Use `precondition`/`postcondition` to gate.
- uses `each.value` inside a `dynamic` block intending the outer iterator — shadowed by the inner block name; rename with `iterator = ...`
- emits hardcoded cloud IDs/ARNs (`vpc-0abc...`, pattern-matched `arn:aws:iam::` patterns) from training data instead of using data sources or input variables
- pairs `password_wo` with `aws_secretsmanager_secret_version` — the data source still reads `secret_string` into state on refresh. Use `ephemeral` (1.10+) or CI-injected env var.
- iterates `dynamic` blocks over `toset(...)` of maps/objects — the set's undefined ordering causes non-deterministic block ordering in the plan diff; sort the list or use a map keyed by a stable field
