## Dependency Caching

Caching can reduce build times by up to 80% by reusing downloaded dependencies.

### Prefer official setup actions

Use the official setup action for your project's stack when one exists — they handle cache keys, restore, and tool installation:

```yaml
# Node.js (this repo: .opencode/package.json)
- uses: actions/setup-node@49933ea528805ca138fa932375564195e1542332 # v4.4.0
  with:
    node-version: "20"
    cache: "npm" # auto-detects lockfiles in the working directory

# Python (this repo: modules/.../pyproject.toml)
- uses: actions/setup-python@42375524e23c412d93fb67b49958b491fce71c38 # v5.4.0
  with:
    python-version: "3.12"
    cache: "pip" # hashes requirements.txt, pyproject.toml, Pipfile, etc.
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
