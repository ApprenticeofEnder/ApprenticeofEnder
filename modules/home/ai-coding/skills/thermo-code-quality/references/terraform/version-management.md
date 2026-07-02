# Version Management

Flag a finding for each rule violated in the diff. Cite the rule by ID.

#### `version-constraint-syntax`

Prefer the pessimistic constraint (`~>`) for stability. Flag unpinned constraints (no version, or bare `>=`) as drift risk, and exact pins (`= "5.0.0"`) as needlessly inflexible except where `pin-strategy-by-component` requires them.

```hcl
version = "~> 5.0"      # 5.x: >= 5.0, < 6.0
version = "~> 5.0.1"    # 5.0.x patches only
version = ">= 5.0"      # risky — allows breaking major bumps
```

#### `pin-strategy-by-component`

Pinning strategy depends on the component. Flag mismatches (e.g. an unpinned provider, or a floating module version in production).

| Component         | Strategy    | Example                       |
| ----------------- | ----------- | ----------------------------- |
| Terraform runtime | Pin minor   | `required_version = "~> 1.9"` |
| Providers         | Pin major   | `version = "~> 5.0"`          |
| Modules (prod)    | Pin exact   | `version = "5.1.2"`           |
| Modules (dev)     | Allow patch | `version = "~> 5.1"`          |

#### `commit-lock-file`

`.terraform.lock.hcl` must be committed. Flag a diff that adds providers but omits/ignores the lock file, or that `.gitignore`s it — that reintroduces version drift across machines and CI.

#### `separate-upgrade-pr`

Provider/runtime version bumps should be isolated from functional changes. Flag a PR that mixes a version upgrade with feature work — it makes the blast radius of a breaking change impossible to review cleanly.
