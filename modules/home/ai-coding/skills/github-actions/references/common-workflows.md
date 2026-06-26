# Common Workflows

Stack-agnostic GitHub Actions patterns — structure, security defaults, and CI/CD mechanics. Not language runtimes or cloud SDKs.

**Conventions:** SHA-pinned `uses:` with `# vX.Y.Z` comments (never mutable tags/branches); explicit `permissions`; named steps; `./scripts/ci-*.sh` placeholders for stack work.

---

## 1. Minimal CI Skeleton

```yaml
name: CI
on:
  push: { branches: [main] }
  pull_request: { branches: [main] }
permissions: { contents: read }
concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
jobs:
  build-and-test:
    name: Build and test
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - name: Check out repository
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Restore cache
        uses: actions/cache@0a38140700be2b45c665b798487e87558f4ade18 # v4.2.4
        with:
          path: .cache
          key: deps-${{ runner.os }}-${{ hashFiles('**/lockfile') }}
          restore-keys: deps-${{ runner.os }}-
      - name: Install dependencies
        run: ./scripts/ci-install.sh
      - name: Build
        run: ./scripts/ci-build.sh
      - name: Test
        run: ./scripts/ci-test.sh
```

Always set `timeout-minutes`. Split phases so logs pinpoint failures.

---

## 2. Matrix Builds

OS × configurable target (via matrix or `workflow_dispatch` input). Keep language versions in env/vars, not matrix keys.

```yaml
on:
  workflow_dispatch:
    inputs:
      target: { type: choice, options: [stable, canary, lts], required: true }
  pull_request:
permissions: { contents: read }
jobs:
  matrix-test:
    name: Test (${{ matrix.os }} / ${{ matrix.target }})
    runs-on: ${{ matrix.os }}
    timeout-minutes: 45
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        target: [stable, canary]
        exclude: [{ os: windows-latest, target: canary }]
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Run tests
        env: { CI_TARGET: ${{ matrix.target }} }
        run: ./scripts/ci-test.sh
```

---

## 3. Reusable Workflows

`.github/workflows/reusable-test.yml`:

```yaml
on:
  workflow_call:
    inputs:
      target: { required: true, type: string }
      working-directory: { type: string, default: . }
    outputs:
      test-result: { value: ${{ jobs.test.outputs.result }} }
    secrets:
      REGISTRY_TOKEN: { required: false }
permissions: { contents: read }
jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    outputs: { result: ${{ steps.test.outputs.result }} }
    defaults: { run: { working-directory: ${{ inputs.working-directory }} } }
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - id: test
        env:
          CI_TARGET: ${{ inputs.target }}
          REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
        run: ./scripts/ci-test.sh && echo "result=pass" >> "$GITHUB_OUTPUT"
```

Caller: `uses: ./.github/workflows/reusable-test.yml` with `with:` / `secrets:` / `needs:` as required.

---

## 4. Service Containers

Postgres + Redis health-check pattern for integration tests.

```yaml
jobs:
  integration:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    services:
      postgres:
        image: postgres:16
        env: { POSTGRES_USER: ci, POSTGRES_PASSWORD: ci, POSTGRES_DB: app_test }
        ports: ['5432:5432']
        options: >-
          --health-cmd "pg_isready -U ci -d app_test"
          --health-interval 10s --health-timeout 5s --health-retries 5
      redis:
        image: redis:7-alpine
        ports: ['6379:6379']
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s --health-timeout 5s --health-retries 5
    env:
      DATABASE_URL: postgres://ci:ci@localhost:5432/app_test
      REDIS_URL: redis://localhost:6379
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - run: ./scripts/ci-integration.sh
```

---

## 5. Artifacts — Upload / Download Between Jobs

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - run: ./scripts/ci-build.sh
      - uses: actions/upload-artifact@b4b4815c4628a84945d9862f9259a6083a1a5497 # v4.6.2
        with:
          name: dist-${{ github.sha }}
          path: dist/
          retention-days: 7
          if-no-files-found: error
  deploy-preview:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@fa0a085b26b0e0776539a3210667e7da5e8b9612 # v4.1.8
        with: { name: dist-${{ github.sha }}, path: dist/ }
      - run: ./scripts/ci-publish-preview.sh dist/
```

Name artifacts with `${{ github.sha }}` or matrix coords to avoid collisions.

---

## 6. Concurrency — Cancel In Progress

```yaml
# CI feedback loops
concurrency: { group: ${{ github.workflow }}-${{ github.ref }}, cancel-in-progress: true }
# Stateful deploys
concurrency: { group: deploy-production, cancel-in-progress: false }
```

---

## 7. Path Filters

```yaml
on:
  pull_request:
    paths: ['src/**', 'packages/**', '.github/workflows/ci.yml']
    paths-ignore: ['**/*.md', 'docs/**']
  push:
    branches: [main]
    paths: ['src/**', 'packages/**']
```

Filters apply to the latest push commit, not full PR diffs — pair with monorepo detection (§9).

---

## 8. Deployment Skeleton — OIDC + Environment Protection

```yaml
name: Deploy
on:
  push: { branches: [main] }
  workflow_dispatch:
    inputs:
      environment: { type: choice, options: [staging, production], required: true }
permissions:
  contents: read
  id-token: write
  deployments: write
concurrency:
  group: deploy-${{ inputs.environment || 'staging' }}
  cancel-in-progress: false
jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    environment: ${{ inputs.environment || 'staging' }}
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Assume cloud role via OIDC
        run: echo "Use provider OIDC action from stack skill"
      - run: ./scripts/deploy.sh
```

Configure environment protection rules: required reviewers, branch limits, env-scoped secrets, optional wait timer.

---

## 9. Monorepo — Path Filter + workflow_call

```yaml
on: { pull_request: {}, push: { branches: [main] } }
permissions: { contents: read }
jobs:
  changes:
    runs-on: ubuntu-latest
    outputs: { packages: ${{ steps.filter.outputs.changes }} }
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - id: filter
        run: echo "changes=$(./scripts/changed-packages.sh)" >> "$GITHUB_OUTPUT"
  test:
    needs: changes
    if: needs.changes.outputs.packages != '[]'
    strategy:
      fail-fast: false
      matrix: { package: ${{ fromJSON(needs.changes.outputs.packages) }} }
    uses: ./.github/workflows/reusable-test.yml
    with: { target: stable, working-directory: ${{ matrix.package }} }
```

`changed-packages.sh` emits a JSON array of package directory paths — no Nx-specific actions.

---

## 10. CI Meta-Workflow — actionlint + zizmor

```yaml
name: Lint workflows
on:
  pull_request:
    paths: ['.github/workflows/**', '.github/actions/**']
permissions: { contents: read }
jobs:
  validate:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Run actionlint
        run: |
          curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash | bash -s -- 1.7.12
          ./actionlint -color
      - uses: zizmorcore/zizmor-action@5f14fd08f7cf1cb1609c1e344975f152c7ee938d # v0.5.6
        with: { workflows: .github/workflows }
```

actionlint has no official Action — pin the CLI. zizmor scans for supply-chain and permissions issues.

---

## Stack-Specific CI

**Never embed language- or platform-specific CI in the github-actions skill.** Load the relevant skill first.

| Stack | Reference |
|-------|-----------|
| Terraform / OpenTofu | [terraform/references/ci-cd-workflows.md](../../terraform/references/ci-cd-workflows.md) |
| TanStack | [tanstack skill](../../tanstack/SKILL.md) |
| .NET / C# | [dotnet-dev-guidelines skill](../../dotnet-dev-guidelines/SKILL.md) |

1. Use this file for workflow structure and security defaults.
2. Load the stack skill for install/test/deploy and cloud OIDC actions.
3. Pin all third-party actions to commit SHAs.
4. Keep reusable `inputs`/`outputs`/`secrets` stable; put stack logic in `./scripts/`.
