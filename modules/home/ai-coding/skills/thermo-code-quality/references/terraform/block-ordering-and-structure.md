# Block Ordering & Structure

Flag a finding for each rule violated in the diff. Cite the rule by ID.

#### `resource-block-ordering`

Resource arguments must follow a strict order: `count`/`for_each` first (blank line after) → arguments → `tags` → `depends_on` → `lifecycle`. Flag out-of-order blocks; they make resources harder to scan and diff.

Bad:

```hcl
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this[0].id
  tags          = { Name = "nat" }
  count         = var.create_nat_gateway ? 1 : 0  # should be first
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.this]     # should be after tags
}
```

Good:

```hcl
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "${var.name}-nat"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}
```

The same ordering applies on Azure/GCP resources.

#### `variable-block-ordering`

Variable blocks must order: `description` → `type` → `default` → `sensitive` → `nullable` → `validation`. Flag reordered or scattered variable definitions.

Good:

```hcl
variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
  nullable    = false

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
```

#### `missing-variable-description`

Every `variable` and `output` must have a `description`. Flag any missing one — this is a maintainability regression on a module contract.

#### `variable-type-preference`

Prefer simple types (`string`, `number`, `list()`, `map()`) and `optional()` typed object attributes (1.3+) over untyped `map(any)` / `any` on long-lived contracts. Reserve `any` for cases that genuinely support multiple types. Flag loose typing that erodes the module contract.

Bad:

```hcl
variable "mixed_config" {
  description = "Configuration with varying types"
  type        = any            # loose contract, no validation
}
```

Good:

```hcl
variable "database_config" {
  description = "Database configuration with optional parameters"
  type = object({
    name               = string
    engine             = string
    instance_class     = string
    backup_retention   = optional(number, 7)
    monitoring_enabled = optional(bool, true)
    tags               = optional(map(string), {})
  })
}
```

#### `output-naming`

Outputs follow `{name}_{type}_{attribute}`, omit the `this_` prefix, and use plural names for list-valued outputs. Flag `this_`-prefixed or singular-named list outputs.

Bad:

```hcl
output "this_security_group_id" {   # drop "this_"
  value = aws_security_group.this[0].id
}

output "subnet_id" {                # returns a list — should be plural
  value = aws_subnet.private[*].id
}
```

Good:

```hcl
output "security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.this[0].id, "")
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}
```
