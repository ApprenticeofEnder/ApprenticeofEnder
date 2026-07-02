# Count vs For_Each

Flag a finding for each rule violated in the diff. Cite the rule by ID.

#### `count-index-identity`

Never use a list index (`count.index`) as long-lived resource identity. Removing a middle element reshuffles every address after it, forcing needless destroy/recreate. Treat this as a correctness/blast-radius bug, not a style nit.

Bad:

```hcl
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
  # removing var.availability_zones[1] recreates all subsequent subnets
}
```

Good:

```hcl
resource "aws_subnet" "private" {
  for_each          = toset(var.availability_zones)
  availability_zone = each.key
  # removing one AZ destroys only that subnet
}
```

#### `prefer-foreach-stable-keys`

Use `for_each` (over a map/set) for named resources, resources referenced by key, or collections whose members may be added/removed. Flag `count` used for anything where identity stability matters.

#### `count-for-boolean-only`

`count` is appropriate for a boolean create/don't toggle (`count = var.enabled ? 1 : 0`) or simple fixed numeric replication where order never matters. Flag `count` used as a general collection mechanism.

```hcl
# acceptable count use — optional singleton
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0
}
```

#### `foreach-keys-known-at-plan`

`for_each` keys must be resolvable at plan time. Flag keys derived from another resource's computed attributes (IDs, ARNs) — planning fails with `Invalid for_each argument`. `depends_on` does not fix this; it orders applies, not plan-time value resolution.

Bad:

```hcl
resource "aws_eip" "web" {
  for_each = toset([for i in aws_instance.web : i.id])  # computed IDs — plan fails
  instance = each.key
}
```

Good:

```hcl
resource "aws_eip" "web" {
  for_each = var.instances                    # user-supplied keys
  instance = aws_instance.web[each.key].id
}

# when the exact ID is not known at plan, use a singleton instead
resource "aws_eip" "bastion" {
  count    = var.create_bastion ? 1 : 0
  instance = aws_instance.bastion[0].id
}
```

#### `missing-moved-on-count-migration`

A `count` → `for_each` migration must ship `moved` blocks in the same change, or Terraform destroys and recreates every resource. Flag a migration diff that lacks them. Verify `terraform plan` shows move operations, not replacement.

```hcl
moved {
  from = aws_subnet.private[0]
  to   = aws_subnet.private["us-east-1a"]
}
moved {
  from = aws_subnet.private[1]
  to   = aws_subnet.private["us-east-1b"]
}
```
