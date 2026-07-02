# Modern Terraform Features (1.0+)

Flag a finding for each rule violated in the diff. Cite the rule by ID.

#### `feature-version-floor`

Every modern feature has a runtime floor. Flag a diff that emits a feature above the declared `required_version`, or that silently uses a 1.11+/1.10+ feature (S3 native lock, `write_only`, `removed`, `ephemeral`) without confirming the floor. If the target runtime is below a feature's floor, the pre-floor fallback must be used explicitly.

| Feature                       | Min version |
| ----------------------------- | ----------- |
| `try()`                       | 0.12.20+    |
| `nonsensitive()`              | 0.15+       |
| `nullable = false`            | 1.1+        |
| `moved` blocks                | 1.1+        |
| `optional()` with defaults    | 1.3+        |
| `import` / `check` blocks     | 1.5+        |
| native `terraform test`       | 1.6+        |
| mock providers / `removed`    | 1.7+        |
| provider-defined functions    | 1.8+        |
| cross-variable validation     | 1.9+        |
| S3 native lock / `ephemeral`  | 1.10+       |
| `write_only` arguments        | 1.11+       |

#### `prefer-try-over-concat`

On 0.12.20+, use `try()` for fallbacks. Flag the legacy `element(concat(...))` pattern.

Bad:

```hcl
output "security_group_id" {
  value = element(concat(aws_security_group.this[*].id, [""]), 0)
}
```

Good:

```hcl
output "security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.this[0].id, "")
}
```

#### `nullable-false`

On 1.1+, set `nullable = false` on variables that must never be `null`, so passing `null` uses the default rather than silently overriding it. Flag its absence where a default exists and `null` is meaningless.

#### `optional-with-defaults`

On 1.3+, model optional object attributes with `optional(type, default)` rather than wrapper variables or loose `map(any)`. Flag wrapper-variable workarounds. See also `variable-type-preference` in [block-ordering-and-structure](./block-ordering-and-structure.md).

#### `moved-not-destroy`

Renaming a resource or module address without a `moved` block silently turns the rename into destroy/create. Flag any address rename in the diff that lacks a matching `moved` block.

```hcl
moved {
  from = aws_instance.web_server
  to   = aws_instance.web
}
```

#### `moved-boundary-limits`

`moved` cannot cross a provider boundary or a state/backend key, and a `moved` block placed **inside** a module that is itself being removed silently no-ops (resources get destroyed). Flag these misuses. Alternatives: `removed` (1.7+) + `import` (1.5+) across providers; `state mv` + backup across backends; place the `moved` in the **parent** when removing a module.

#### `ignore-changes-scope`

Flag `ignore_changes = all` and broad ignore lists — they hide real drift and turn attributes unmanaged. Ignoring should be attribute-scoped with a comment naming the external system that mutates it. Never use `ignore_changes` to silence a noisy plan instead of diagnosing the drift.

Bad:

```hcl
lifecycle {
  ignore_changes = all
}
```

Good:

```hcl
lifecycle {
  # External compliance scanner rewrites this tag hourly
  ignore_changes = [tags["LastScanned"]]
}
```

#### `check-is-advisory`

A `check` block (1.5+) is advisory — it emits warnings, it does **not** block apply. Flag code that relies on `check` to gate apply. Use `variable validation`, `precondition`, or `postcondition` for anything that must block.

| Mechanism                        | Blocks apply? |
| -------------------------------- | ------------- |
| `validation` (in `variable`)     | yes           |
| `precondition` (in `lifecycle`)  | yes           |
| `postcondition` (in `lifecycle`) | yes           |
| `check` block (1.5+)             | **no — advisory only** |

#### `writeonly-secrets`

Marking a variable `sensitive = true` does **not** keep its value out of state — it only masks display. Flag secrets that land in state. On 1.11+ use `*_wo` (write-only) arguments; otherwise source from an external secret manager. Note that pairing `password_wo` with `aws_secretsmanager_secret_version` still reads `secret_string` into state on refresh — for true exclusion use `ephemeral` (1.10+), `manage_master_user_password`, or a CI-injected env var.

Bad:

```hcl
resource "aws_db_instance" "this" {
  password = var.db_password          # ends up in state
}
```

Good:

```hcl
resource "aws_db_instance" "this" {
  password_wo = data.aws_secretsmanager_secret_version.db_password.secret_string  # 1.11+
}
```

#### `nonsensitive-leak`

Flag `nonsensitive()` used to unwrap a genuine secret so it stops appearing in plan output — that launders the secret into plan artifacts and CI logs. `nonsensitive()` is only safe for values provably not secret.

#### `ephemeral-vs-sensitive`

Do not conflate `sensitive = true` (masks display, still in state) with `ephemeral` (1.10+, scrubbed from state and plan). For short-lived credentials that must never persist, only `ephemeral` is correct. Flag `sensitive` used where the intent is to keep material out of state.

#### `dynamic-iterator-shadowing`

Inside a nested `dynamic` block, the block-name iterator shadows the outer `each.*`. Flag a `dynamic "ingress"` whose body needs the outer iterator but references the shadowed name. Rename the inner iterator with `iterator = rule`.

```hcl
dynamic "ingress" {
  for_each = each.value.rules
  iterator = rule
  content {
    from_port   = rule.value.from_port
    description = each.value.description  # outer iterator stays reachable
  }
}
```

#### `dynamic-set-ordering`

Iterating a `dynamic` block over `toset([...])` of maps/objects yields non-deterministic block ordering in the plan diff (sets have no defined order). Flag it; drive the iteration from a sorted list or a map keyed by a stable field instead.
