# Validation Tooling

Single source of truth for validating GitHub Actions workflows and custom actions before merge or deployment.

Both tools are available in the user's Nix profile: `actionlint` and `zizmor` (see `modules/home/packages.nix` — `actionlint` in `devops`, `zizmor` in `security`).

## Evaluation Order

Run tools in this order and re-run until clean:

1. **actionlint** — syntax, semantics, expressions, runner labels
2. **zizmor --offline** — security static analysis without network
3. **Re-run** both until zero diagnostics
4. **Optional:** `zizmor` online (when rules need GitHub API context)

---

## actionlint

### Purpose

- YAML syntax validation for workflow files
- Workflow semantics (jobs, steps, triggers, reusable workflows)
- Expression typing (`${{ }}` context and type errors)
- Runner label validation (`runs-on` values)

### Local Commands

```bash
actionlint .github/workflows/
actionlint -oneline .github/workflows/
actionlint -shellcheck= .github/workflows/   # disable shellcheck integration
```

### Scope

- `.github/workflows/` — workflow files
- Reusable workflows (local and remote `uses:` targets)
- `.github/actions/` — composite and other custom actions

### CI Integration

Prefer running the `actionlint` binary directly in CI (fast, no third-party action dependency):

```yaml
- name: Lint workflows
  run: actionlint .github/workflows/
```

If using [rhysd/actionlint](https://github.com/rhysd/actionlint) as a GitHub Action, **pin to a full 40-character commit SHA**, not a version tag:

```yaml
# Prefer the binary; if you must use the action:
- uses: rhysd/actionlint@<40-char-sha> # vX.Y.Z
```

### Pass Criteria

**Zero diagnostics.** Any warning or error is a failure until resolved.

---

## zizmor

### Purpose

Security-focused static analysis for GitHub Actions:

- Unpinned action refs (`uses:` without commit SHA)
- Overly broad or missing `permissions`
- Template injection (`${{ }}` in untrusted contexts)
- Dangerous triggers (`pull_request_target`, `workflow_run`, etc.)
- Cache poisoning patterns
- Credential persistence and leakage risks

### Local Commands

**Default (offline, no GitHub API):**

```bash
zizmor --offline .github/workflows/
```

**Online (needs GitHub API for some rules):**

```bash
GH_TOKEN=$(gh auth token) zizmor .github/workflows/
```

**PR / CI annotation output:**

```bash
zizmor --format=github .
```

### Configuration

- Project config: `.github/zizmor.yml`
- Inline suppressions: `# zizmor: ignore[rule-id]` — **only with a justification comment on the same or preceding line**

Example:

```yaml
# Justified: fork PRs cannot reach this secret; job is gated to internal actors
permissions: write-all # zizmor: ignore[overly-broad-permissions]
```

### Pass Criteria

**Zero findings** at the configured severity threshold. Summarize findings by severity: **error → warning → note → help**.

---

## CI Examples (SHA-Pinned)

All `uses:` references below use full 40-character commit SHAs with `# vX.Y.Z` comments.

### Via zizmor-action (recommended for most repos)

```yaml
name: GitHub Actions Security Analysis with zizmor

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["**"]

permissions: {}

jobs:
  zizmor:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
      actions: read
    steps:
      - name: Checkout repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          persist-credentials: false

      - name: Run zizmor
        uses: zizmorcore/zizmor-action@5f14fd08f7cf1cb1609c1e344975f152c7ee938d # v0.5.6
```

### Without GitHub Advanced Security (annotations mode)

```yaml
      - name: Run zizmor
        uses: zizmorcore/zizmor-action@5f14fd08f7cf1cb1609c1e344975f152c7ee938d # v0.5.6
        with:
          advanced-security: false
          annotations: true
```

### Manual integration (uv + zizmor CLI)

```yaml
jobs:
  zizmor:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Checkout repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        with:
          persist-credentials: false

      - name: Install uv
        uses: astral-sh/setup-uv@08807647e7069bb48b6ef5acd8ec9567f424441b # v8.1.0

      - name: Run zizmor
        run: uvx "zizmor@${ZIZMOR_VERSION}" --format=github .
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          ZIZMOR_VERSION: "0.5.6"
```

### Combined validation job (actionlint + zizmor offline)

```yaml
jobs:
  validate-workflows:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

      - name: actionlint
        run: actionlint .github/workflows/

      - name: zizmor (offline)
        run: zizmor --offline .github/workflows/
```

---

## Explicitly Forbidden in Skill Guidance

Do **not** recommend or rely on these as primary workflow validators or security proxies:

| Tool / Pattern | Why Forbidden |
| -------------- | ------------- |
| **grep / regex secret scanning** | High false-positive rate; misses structured secret patterns; not a substitute for zizmor or platform secret scanning |
| **yamllint** | Validates YAML formatting only — does not understand workflow semantics, expressions, or security |

Use **actionlint** for correctness and **zizmor** for security. For language-specific CI (test runners, package managers, deploy targets), defer to the appropriate stack skill.
