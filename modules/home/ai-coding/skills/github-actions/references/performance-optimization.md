# Performance Optimization

Strategies to reduce workflow execution time and resource usage.

## Performance Impact Hierarchy

1. **Caching** (80% time reduction potential) - Biggest impact
2. **Parallelization** (50%+ reduction for independent jobs)
3. **Selective triggers** (Avoid unnecessary runs)
4. **Concurrency control** (Cancel obsolete runs)
5. **Self-hosted runners** (For heavy workloads)
6. **Workflow optimization** (Remove unnecessary steps)

## Dependency Caching

Caching can reduce build times by up to 80% by reusing downloaded dependencies.

### Prefer official setup actions

Use the official setup action for your project's stack when one exists — they handle cache keys, restore, and tool installation:

```yaml
# Node.js (this repo: .opencode/package.json)
- uses: actions/setup-node@49933ea528805ca138fa932375564195e1542332 # v4.4.0
  with:
    node-version: "20"
    cache: "npm"  # auto-detects lockfiles in the working directory

# Python (this repo: modules/.../pyproject.toml)
- uses: actions/setup-python@42375524e23c412d93fb67b49958b491fce71c38 # v5.4.0
  with:
    python-version: "3.12"
    cache: "pip"  # hashes requirements.txt, pyproject.toml, Pipfile, etc.
```

Check each setup action's README for supported `cache` values and lock file detection.

### Fallback: actions/cache

When no setup action fits (e.g. Nix/flake.lock, Go modules, custom tooling), pin `actions/cache` and hash lock files:

```yaml
- uses: actions/cache@0a38140700be2b45c665b798487e87558f4ade18 # v4.2.4
  with:
    path: |
      ~/.cache/custom
      vendor/
    key: ${{ runner.os }}-deps-${{ hashFiles('**/flake.lock', '**/go.sum', '**/*lock*', '**/*.lock') }}
    restore-keys: |
      ${{ runner.os }}-deps-
```

**Lock file patterns to include in `hashFiles()`:**

- `**/go.sum` — Go modules
- `**/*lock*`, `**/*.lock` — generic (Gemfile.lock, package-lock.json, yarn.lock, pnpm-lock.yaml, poetry.lock, Cargo.lock, flake.lock, etc.)
- Project-specific paths as needed

**Cache key best practices:**

- Include OS: `${{ runner.os }}`
- Hash lock files with the patterns above
- Version prefix: `v1-${{ runner.os }}-...` (for cache invalidation)

**Restore keys** (fallback if exact match not found):

```yaml
restore-keys: |
  v1-${{ runner.os }}-deps-
  v1-${{ runner.os }}-
```

### Docker Layer Caching

```yaml
- uses: docker/setup-buildx-action@e468dbeb0a198661f6a3b1a4aabe3c2a4a2b242c # v3.10.0

- uses: docker/build-push-action@263435318d2637a93775f544927d396be1672c2 # v6.18.0
  with:
    context: .
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### Cache Limits

- Maximum cache size: **10 GB per repository**
- Caches evicted after 7 days of no access
- Pin `actions/cache` v4.2.4+ (v1–v2 retired March 2025)

### Cache Hit Rate

Monitor cache effectiveness:

```yaml
- uses: actions/cache@0a38140700be2b45c665b798487e87558f4ade18 # v4.2.4
  id: cache
  with:
    path: vendor/
    key: ${{ runner.os }}-deps-${{ hashFiles('**/*lock*', '**/*.lock', '**/go.sum') }}

- name: Cache status
  run: |
    if [ "${{ steps.cache.outputs.cache-hit }}" == "true" ]; then
      echo "✅ Cache hit"
    else
      echo "⚠️ Cache miss"
    fi
```

Target: **>80% hit rate** after first run

## Parallelization

### Matrix Builds

Run multiple variations concurrently:

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: ["18", "20", "22"]
        os: [ubuntu-latest, macos-latest]
        include:
          - node-version: "22"
            experimental: true
        exclude:
          - os: macos-latest
            node-version: "18"
      fail-fast: false # Continue if one fails
      max-parallel: 4 # Limit concurrent jobs

    runs-on: ${{ matrix.os }}
    continue-on-error: ${{ matrix.experimental || false }}

    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: actions/setup-node@49933ea528805ca138fa932375564195e1542332 # v4.4.0
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"
      - run: npm test
```

### Independent Jobs

Run jobs in parallel when no dependencies:

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

  # These 3 jobs run in parallel (no 'needs')
```

### Sequential with Dependencies

Only use `needs` when actually required:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

  test:
    needs: build # Waits for build
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  deploy:
    needs: [build, test] # Waits for both
    runs-on: ubuntu-latest
    steps:
      - run: ./deploy.sh
```

### Test Splitting

For large test suites, split across multiple runners:

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2

      # Generic file-based sharding
      - run: |
          files=$(find tests -name '*.test.js' | awk "NR % 4 == ${{ matrix.shard }}")
          npm test -- $files

      # Or use your test runner's built-in sharding (e.g. --shard=${{ matrix.shard }}/4)
      - run: npm test -- --shard=${{ matrix.shard }}/4
```

## Selective Triggers

### Path Filters

Only run when specific files change:

```yaml
on:
  push:
    paths:
      - "src/**"
      - "package.json"
      - "package-lock.json"
    paths-ignore:
      - "**.md"
      - "docs/**"
```

### Branch Filters

```yaml
on:
  push:
    branches:
      - main
      - "releases/**"
  pull_request:
    branches:
      - main
```

### Conditional Jobs

```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
```

### Skip CI

Check commit message for skip directives:

```yaml
jobs:
  test:
    if: "!contains(github.event.head_commit.message, '[skip ci]')"
    runs-on: ubuntu-latest
```

## Concurrency Control

Cancel outdated workflow runs:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

**Use cases:**

- PR pushes (cancel previous commit checks)
- Branch pushes (cancel older runs)

**Don't use for:**

- Deployment workflows (let complete)
- Release workflows (should never cancel)

### Per-workflow concurrency

```yaml
# .github/workflows/ci.yml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

# .github/workflows/deploy.yml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false  # Let deployments complete
```

## Workflow Optimization

### Remove Unnecessary Steps

**Before:**

```yaml
- run: npm install
- run: npm run lint
- run: npm run typecheck
- run: npm test
- run: npm run build
```

**After (combine independent steps):**

```yaml
- run: npm ci # Faster than install
- run: npm run lint & npm run typecheck & wait # Parallel
- run: npm test
- run: npm run build
```

### Shallow Checkout

Don't fetch full history if not needed:

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
  with:
    fetch-depth: 1 # Only fetch latest commit (default)

# Only use fetch-depth: 0 when you need full history
```

### Sparse Checkout

Only checkout specific paths:

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
  with:
    sparse-checkout: |
      src/
      package.json
```

### Minimize Network Requests

```yaml
# ❌ SLOW: Multiple fetches
- run: curl https://example.com/file1.txt
- run: curl https://example.com/file2.txt
- run: curl https://example.com/file3.txt

# ✅ FAST: Parallel or combined
- run: |
    curl -O https://example.com/file1.txt &
    curl -O https://example.com/file2.txt &
    curl -O https://example.com/file3.txt &
    wait
```

### Timeouts

Prevent hanging workflows:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 10 # Job timeout

    steps:
      - name: Long task
        timeout-minutes: 5 # Step timeout
        run: npm test
```

## Self-Hosted Runners

For heavy or frequent workloads, self-hosted runners can be faster.

### Benefits

- **Persistent caching** across runs (no download overhead)
- **Faster startup** (no VM provisioning)
- **Custom hardware** (more CPU, RAM, GPU)
- **Network proximity** to private resources

### Setup

```yaml
jobs:
  build:
    runs-on: [self-hosted, linux, x64]
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - run: npm run build
```

### Caching on Self-Hosted

Persistent directories:

```yaml
# Dependencies stay on disk between runs
- run: |
    if [ ! -d "node_modules" ]; then
      npm ci
    fi
```

### Security Considerations

See [security-checklist.md](security-checklist.md) - self-hosted runners have significant security implications.

## Resource Optimization

### Smaller Docker Images

```dockerfile
# ❌ LARGE: 1.2 GB
FROM node:20

# ✅ SMALL: 200 MB
FROM node:20-slim

# ✅ SMALLEST: 150 MB
FROM node:20-alpine
```

### Multi-stage Docker Builds

```dockerfile
# Build stage
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/index.js"]
```

### Reduce Artifact Size

```yaml
- uses: actions/upload-artifact@b4b4815c4628a84945d9862f9259a6083a1a5497 # v4.6.2
  with:
    name: build
    path: |
      dist/
      !dist/**/*.map  # Exclude source maps
    retention-days: 1 # Clean up quickly
```

## Monitoring Performance

### Workflow Timing

View in Actions UI:

- Total workflow time
- Per-job timing
- Per-step timing

### Identify Bottlenecks

```yaml
- name: Install dependencies
  run: |
    echo "::group::Install dependencies"
    time npm ci
    echo "::endgroup::"

- name: Run tests
  run: |
    echo "::group::Run tests"
    time npm test
    echo "::endgroup::"
```

### Profiling Commands

```yaml
- name: Profile build
  run: |
    time npm run build
    du -sh dist/  # Check output size
```

### Performance Regression Detection

Track execution time over time:

```yaml
- name: Save timing
  run: |
    echo "${{ github.run_number }}: $SECONDS seconds" >> timings.txt
    git add timings.txt
    git commit -m "Add timing data"
    git push
```

## Advanced Caching Strategies

### Cross-Job Caching

```yaml
jobs:
  build:
    steps:
      - run: npm run build
      - uses: actions/cache@0a38140700be2b45c665b798487e87558f4ade18 # v4.2.4
        with:
          path: dist/
          key: build-${{ github.sha }}

  test:
    needs: build
    steps:
      - uses: actions/cache@0a38140700be2b45c665b798487e87558f4ade18 # v4.2.4
        with:
          path: dist/
          key: build-${{ github.sha }}
      - run: npm test
```

### Warm Cache Strategy

Prime cache in off-hours:

```yaml
on:
  schedule:
    - cron: "0 2 * * *" # 2 AM daily

jobs:
  warm-cache:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: actions/setup-node@49933ea528805ca138fa932375564195e1542332 # v4.4.0
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci && echo "Cache warmed"
```

### Multi-level Caching

```yaml
- uses: actions/cache@0a38140700be2b45c665b798487e87558f4ade18 # v4.2.4
  with:
    path: ~/.cache/deps
    key: ${{ runner.os }}-deps-${{ hashFiles('**/*lock*', '**/*.lock', '**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-deps-${{ hashFiles('**/*lock*', '**/*.lock', '**/go.sum') }}
      ${{ runner.os }}-deps-
      ${{ runner.os }}-
```

## Reusable Workflows

Extract common patterns to avoid duplication:

```yaml
# .github/workflows/reusable-test.yml
on:
  workflow_call:
    inputs:
      node-version:
        type: string
        required: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: actions/setup-node@49933ea528805ca138fa932375564195e1542332 # v4.4.0
        with:
          node-version: ${{ inputs.node-version }}
          cache: "npm"
      - run: npm ci && npm test
```

```yaml
# .github/workflows/ci.yml
jobs:
  test-20:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: "20"

  test-22:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: "22"
```

**Benefits:**

- Reduced duplication
- Centralized updates
- Up to 50 workflow calls per run (Nov 2025)
- Up to 10 levels of nesting (Nov 2025)

## Performance Checklist

- [ ] Dependency caching enabled (official setup actions or actions/cache with lock file hashing)
- [ ] Cache hit rate >80% after first run
- [ ] Independent jobs run in parallel (no unnecessary `needs`)
- [ ] Path filters used to skip irrelevant changes
- [ ] Concurrency control cancels outdated runs
- [ ] Timeouts set on long-running jobs/steps
- [ ] Shallow checkout used (fetch-depth: 1)
- [ ] Test suites split across multiple runners (if >5 minutes)
- [ ] Docker images use slim/alpine variants
- [ ] Workflow execution time monitored and optimized
- [ ] Reusable workflows used for common patterns

## Target Metrics

| Workflow Type     | Target Time |
| ----------------- | ----------- |
| Linting           | <2 minutes  |
| Unit tests        | <5 minutes  |
| Integration tests | <10 minutes |
| Full CI           | <15 minutes |
| Deployment        | <10 minutes |

**If exceeding targets:**

1. Enable caching
2. Parallelize independent steps
3. Split test suites
4. Consider self-hosted runners
5. Profile and optimize slow steps

## Resources

- [Caching dependencies](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [actions/cache](https://github.com/actions/cache)
- [Monitoring and troubleshooting workflows](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows)
