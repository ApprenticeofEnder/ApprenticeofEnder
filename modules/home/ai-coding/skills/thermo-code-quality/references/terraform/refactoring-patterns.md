# Refactoring Patterns

Flag a finding for each rule violated in the diff. Cite the rule by ID.

#### `legacy-to-modern-migration`

When a diff touches legacy (0.12/0.13-era) HCL, push for the modern equivalents rather than preserving the old shape. Flag surviving legacy patterns in changed code:

- `element(concat(...))` → `try()` (see `prefer-try-over-concat`)
- variables with meaningful defaults missing `nullable = false`
- object types with optional attributes not using `optional()`
- constraint-bearing variables missing `validation` blocks
- resource refactors missing `moved` blocks
- secrets in variables/state instead of write-only arguments

Bad → Good:

```hcl
# Before (0.12 style)
output "security_group_id" {
  value = element(concat(aws_security_group.this[*].id, [""]), 0)
}

# After (1.x style)
output "security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.this[0].id, "")
}
```

#### `secrets-remediation`

Both `random_password.result` and a `sensitive = true` variable still land the secret in state (`sensitive` only masks display). Flag either shape and push to move secret material out of state entirely. Minimum refactor: source from an external secret manager and, on 1.11+, use the write-only argument.

Bad:

```hcl
resource "random_password" "db" { length = 16 }
resource "aws_db_instance" "this" {
  password = random_password.db.result   # in state
}
```

Good:

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod-database-password"
}
resource "aws_db_instance" "this" {
  # 1.11+; data source still reads secret_string into state on refresh —
  # for true exclusion use ephemeral (1.10+), manage_master_user_password, or a CI env var.
  password_wo = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

Verify the remediation: after apply, `terraform show | grep -i password` must be empty. Pre-1.11 fallback uses the same data source without `password_wo`; rotation happens outside Terraform.
