---
name: github-actions
description: Create, evaluate, and optimize GitHub Actions workflows and custom actions. Use when building CI/CD pipelines, creating workflow files, developing custom actions, troubleshooting workflow failures, performing security analysis, optimizing performance, or reviewing GitHub Actions best practices.
---

# GitHub Actions Skill

Workflow-driven guidance for GitHub Actions CI/CD. Core file is a workflow; depth lives in references loaded on demand.

## Response Contract

Every create, review, or evaluate response **must** include:

1. **Assumptions** — repo visibility (public/private), workflow triggers, runner type (GitHub-hosted vs self-hosted), whether online zizmor is needed for the rules under review.
2. **Pinning policy** — all `uses:` references pin a full 40-character commit SHA with `# vX.Y.Z` comment (see Hard Rule below).
3. **Validation commands run** — exact `actionlint` and `zizmor` invocations and their exit status.
4. **Findings** — tool output summarized; zizmor findings ordered by severity (error → warning → note → help).
5. **Stack deferral** — name the skill to load for language-specific CI (e.g. `terraform`, `tanstack`, `dotnet-dev-guidelines`).

## Hard Rule

> Every third-party and first-party `uses:` reference MUST pin a full 40-character commit SHA. Version tags (`@v4`), semver tags (`@v1.0.0`), and branch refs (`@main`) are never acceptable — including for `actions/*`.

## Mandatory Gates

Before finalizing any workflow change, run both commands and require zero diagnostics:

```bash
actionlint .github/workflows/
zizmor --offline .github/workflows/
```

Re-run until clean. Optionally run online zizmor when rules need GitHub API context:

```bash
GH_TOKEN=$(gh auth token) zizmor .github/workflows/
```

See [Validation Tooling](references/validation-tooling.md) for CI integration patterns, config, and evaluation order.

## Workflow

1. **Capture context** — triggers, runner, repo visibility, secrets/environments involved, whether the workflow touches untrusted input (fork PRs, `pull_request_target`, `workflow_run`).
2. **Diagnose intent** — create new workflow, security review, performance pass, troubleshoot failure, or custom action development. Load only matching references.
3. **Apply security baseline** — minimum `permissions`, SHA-pinned actions, no secrets in logs, safe trigger patterns.
4. **Generate or fix artifacts** — workflow YAML, composite actions, reusable workflows.
5. **Validate** — run mandatory gates (`actionlint`, `zizmor --offline`); optional online zizmor.
6. **Emit Response Contract** — assumptions, pinning, commands, findings, stack deferral.

## Diagnose Before You Generate

| Task | Symptoms / Trigger | Primary references |
| ---- | -------------------- | ------------------ |
| **Create workflow** | New CI/CD pipeline, deploy job, PR checks | [Common Workflows](references/common-workflows.md), [Workflow Syntax](references/workflow-syntax.md) |
| **Security review** | Unpinned refs, broad permissions, fork PR exposure | [Validation Tooling](references/validation-tooling.md), [Security Checklist](references/security-checklist.md) |
| **Performance pass** | Slow runs, missing cache, serial jobs | [Performance Optimization](references/performance-optimization.md) |
| **Troubleshoot failure** | Failed job, permission errors, cache miss | [Troubleshooting](references/troubleshooting.md) |
| **Custom action** | Reusable step logic, composite/JS/Docker action | [Custom Actions](references/custom-actions.md) |
| **Audit / evaluate** | Pre-merge review, compliance check | [Evaluation Guide](references/evaluation-guide.md), [Validation Tooling](references/validation-tooling.md) |

## When to Use This Skill

**Activate when:** creating or reviewing workflow files, developing custom actions, debugging CI failures, optimizing workflow performance, or hardening Actions security posture.

**Don't use for:** language-specific test/build/deploy logic — load the stack skill (`terraform`, `tanstack`, `dotnet-dev-guidelines`, etc.) for runner setup, caching keys, and deploy steps.

## Core Principles

### Pinning

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

Resolve SHAs from the action's release tag or commit history. Never leave `@v4`, `@main`, or semver tags in generated output.

### Permissions

Default to read-only. Grant write scopes only where required:

```yaml
permissions:
  contents: read
```

Add `id-token: write` only for OIDC cloud deployments. See [Security Checklist](references/security-checklist.md).

### Triggers

Match triggers to intent. Use path filters and concurrency to limit run cost:

```yaml
on:
  pull_request:
    paths:
      - ".github/workflows/**"
      - "src/**"

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Reusable Workflows

```yaml
# .github/workflows/reusable.yml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string

permissions:
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying to ${{ inputs.environment }}"
```

```yaml
jobs:
  call-reusable:
    uses: ./.github/workflows/reusable.yml
    with:
      environment: production
```

### Matrix Builds (stack-neutral)

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    tool-version: ["1.0", "2.0"]
jobs:
  test:
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - run: ./scripts/test.sh ${{ matrix.tool-version }}
```

Defer language-specific matrix dimensions and setup actions to the stack skill.

### Caching

Use `actions/cache` with lockfile-derived keys. Pin the cache action to a SHA:

```yaml
# Pin actions/cache to a full 40-char SHA before use — see Hard Rule
- uses: actions/cache@0a38140700be2b45c665b798487e87558f4ade18 # v4.2.4
  with:
    path: ~/.cache/example
    key: ${{ runner.os }}-example-${{ hashFiles('**/lockfile') }}
```

Stack skills define which paths and lockfiles to hash.

## Forbidden Patterns

Do **not** recommend:

- **grep / regex secret scanning** as a workflow security control
- **yamllint** as primary validator or security proxy
- **Version tags, semver tags, or branch refs** in any `uses:` line
- **`pull_request_target`** checking out untrusted PR code without an approval gate

## Anti-Patterns

- Overly broad `permissions:` or omitting explicit permissions
- Hardcoded secrets instead of GitHub Secrets / OIDC
- Sequential jobs that could run in parallel
- Missing `timeout-minutes` (default 6-hour job limit)
- `fetch-depth: 0` on checkout when full history is not needed
- Unpinned third-party actions, including `actions/*`

See [Security Checklist](references/security-checklist.md) and [Troubleshooting](references/troubleshooting.md) for expanded lists.

## Local Testing

Use `act` for approximate local runs. Always validate with mandatory gates before push — `act` does not replace actionlint or zizmor.

## Reference Files

Progressive disclosure — essentials here, depth on demand:

- [Validation Tooling](references/validation-tooling.md) — actionlint + zizmor commands, CI examples, evaluation order
- [Common Workflows](references/common-workflows.md) — generic workflow patterns and templates
- [Workflow Syntax](references/workflow-syntax.md) — triggers, jobs, steps, expressions
- [Custom Actions](references/custom-actions.md) — JavaScript, Docker, and composite actions
- [Security Checklist](references/security-checklist.md) — permissions, OIDC, secret handling
- [Performance Optimization](references/performance-optimization.md) — caching, parallelization, profiling
- [Troubleshooting](references/troubleshooting.md) — debugging workflows, common errors
- [Evaluation Guide](references/evaluation-guide.md) — audit checklist and review methodology
