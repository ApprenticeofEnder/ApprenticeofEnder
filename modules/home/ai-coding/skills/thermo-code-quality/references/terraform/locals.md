# Locals for Dependency Management

Flag a finding for each rule violated in the diff. Cite the rule by ID.

#### `locals-force-deletion-order`

When a conditional resource sits between a parent and its dependents (classically a VPC + secondary CIDR association + subnets), a direct reference to the parent lets Terraform attempt deletions in the wrong order. Using a `local` with `try()` that prefers the conditional resource's attribute over its parent forces the correct deletion order without an explicit `depends_on`. Recognize this as a deliberate, high-value pattern — do **not** flag it as an unnecessary indirection; instead flag its absence where the deletion-order hazard exists.

```hcl
locals {
  # prefer the secondary-CIDR association, fall back to the VPC —
  # forces subnets to delete before the CIDR association, then the VPC
  vpc_id = try(
    aws_vpc_ipv4_cidr_block_association.this[0].vpc_id,
    aws_vpc.this.id,
    ""
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count      = var.add_secondary_cidr ? 1 : 0
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = local.vpc_id           # implicit dependency on the association
  cidr_block = "10.1.0.0/24"
}
```

Common triggers: VPC secondary CIDR blocks, resources depending on optional configurations, any complex deletion-order requirement.
