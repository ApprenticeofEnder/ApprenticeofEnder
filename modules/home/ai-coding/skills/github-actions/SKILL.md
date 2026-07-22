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

## Hard Rule

> Every third-party and first-party `uses:` reference MUST pin a full 40-character commit SHA. Version tags (`@v4`), semver tags (`@v1.0.0`), and branch refs (`@main`) are never acceptable — including for `actions/*`.

### Why SHA-Only?

- Tags can be force-pushed and changed
- Branch refs can be updated maliciously
- Commit SHAs are immutable
- Prevents supply chain attacks

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

## Core Principles

- **Action Pinning**: Resolve SHAs from the action's release tag or commit history. Never leave `@v4`, `@main`, or semver tags in generated output.
  - To get the release SHA of an action, see [the reference page](references/sha-pinning.md).
- **Permissions**: Default to read-only. Grant write scopes only where required. See [the reference page](references/permissions.md) for more details.
  - **OIDC**: Add `id-token: write` only for OIDC cloud deployments.
- **Triggers**: Match triggers to intent. Use path filters and concurrency to limit run cost.
- **No Duplicated Logic**: Duplicated logic must be rewritten to use reusable workflows, custom actions, or strategy matrices as appropriate.

## Common Patterns

- **Caching**: Used to save commonly used files between runs (e.g. NPM packages). [Examples](references/caching.md)
- **Service Containers**: Used when you need Docker containers to run within an action. [Example](references/service-container.md)
- **Artifact Upload/Download**: Used to persist artifacts between runs of an action, or between jobs. [Example](references/artifact-persistence.md)
- **Concurrency**: Used to avoid collisions between separate runs of the same workflow. [Example](references/concurrency.md)
- **Sharding**: Used to split large operations across multiple runners. [Example](references/sharding.md)
- **Parallel Steps**: Used to run steps in a job that do not depend on each other. [Example](references/parallel-steps.md)
- **Alternate Checkouts**: Checkout the minimum commit history and paths needed to complete a task. [Example](references/alternate-checkouts.md)
