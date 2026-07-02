## Block Ordering & Structure

### Resource Block Structure

**Strict argument ordering:**

1. `count` or `for_each` FIRST (blank line after)
2. Other arguments (alphabetical or logical grouping)
3. `tags` as last real argument
4. `depends_on` after tags (if needed)
5. `lifecycle` at the very end (if needed)

```hcl
# ✅ GOOD - Correct ordering
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

# ❌ BAD - Wrong ordering
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this[0].id

  tags = { Name = "nat" }

  count = var.create_nat_gateway ? 1 : 0  # Should be first

  subnet_id = aws_subnet.public[0].id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_internet_gateway.this]  # Should be after tags
}
```

> Pattern applies identically on Azure/GCP; for resource equivalents see [Module Patterns: Cross-cloud resource map](module-patterns.md#cross-cloud-resource-map).

### Variable Definition Structure

**Variable block ordering:**

1. `description` (ALWAYS required)
2. `type`
3. `default`
4. `sensitive` (when setting to true)
5. `nullable` (when setting to false)
6. `validation`

```hcl
# ✅ GOOD - Correct ordering and structure
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

### Variable Type Preferences

- Prefer **simple types** (`string`, `number`, `list()`, `map()`) over `object()` unless strict validation needed
- Use `optional()` for optional object attributes (Terraform 1.3+)
- Use `any` to disable validation at certain depths or support multiple types

**Modern variable patterns (Terraform 1.3+):**

```hcl
# ✅ GOOD - Using optional() for object attributes
variable "database_config" {
  description = "Database configuration with optional parameters"
  type = object({
    name               = string
    engine             = string
    instance_class     = string
    backup_retention   = optional(number, 7)      # Default: 7
    monitoring_enabled = optional(bool, true)     # Default: true
    tags               = optional(map(string), {}) # Default: {}
  })
}

# Usage - only required fields needed
database_config = {
  name           = "mydb"
  engine         = "mysql"
  instance_class = "db.t3.micro"
  # Optional fields use defaults
}
```

**Complex type example:**

```hcl
# For lists/maps of same type
variable "subnet_configs" {
  description = "Map of subnet configurations"
  type        = map(map(string))  # All values are maps of strings
}

# When types vary, use any
variable "mixed_config" {
  description = "Configuration with varying types"
  type        = any
}
```

### Output Structure

**Pattern:** `{name}_{type}_{attribute}`

```hcl
# ✅ GOOD
output "security_group_id" {  # "this_" should be omitted
  description = "The ID of the security group"
  value       = try(aws_security_group.this[0].id, "")
}

output "private_subnet_ids" {  # Plural for list
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# ❌ BAD
output "this_security_group_id" {  # Don't prefix with "this_"
  value = aws_security_group.this[0].id
}

output "subnet_id" {  # Should be plural "subnet_ids"
  value = aws_subnet.private[*].id  # Returns list
}
```
