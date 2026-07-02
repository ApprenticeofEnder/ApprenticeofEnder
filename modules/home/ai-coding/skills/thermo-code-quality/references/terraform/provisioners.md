# Provisioners as Last Resort

Flag a finding for each rule violated in the diff. Cite the rule by ID.

#### `provisioners-last-resort`

Provisioners (`local-exec` / `remote-exec`, `null_resource`) are a last resort. Flag them where a declarative mechanism fits:

| Goal                                      | Prefer                                                                  |
| ----------------------------------------- | ----------------------------------------------------------------------- |
| Instance bootstrap                        | `user_data` + cloud-init via `templatefile()`                           |
| Orchestration with explicit re-run (1.4+) | `terraform_data` + `triggers_replace`                                   |
| Ongoing OS config                         | External: Ansible / SSM Run Command / SSM State Manager                 |
| Last-resort one-shot                      | `terraform_data` + `provisioner` (1.4+) or `null_resource` (pre-1.4)    |

Bad:

```hcl
resource "null_resource" "bootstrap" {
  provisioner "local-exec" {
    command = "ssh ec2-user@${aws_instance.web.public_ip} 'bash setup.sh'"
  }
}
```

Good:

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.small"
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    app_version = var.app_version
  })
  user_data_replace_on_change = true
}
```

#### `provisioner-cost-awareness`

Where a provisioner is genuinely unavoidable, flag the diff if it ignores their costs: they are non-idempotent (re-runs duplicate side effects), create-only (updates don't re-run; `when = destroy` is fragile), invisible to drift detection, and their stdout/stderr leaks to CI logs where `sensitive` will **not** redact it. `remote-exec` additionally requires SSH/WinRM reachability from the runner. Prefer `terraform_data` + `triggers_replace` for a declarative, re-runnable shape.
