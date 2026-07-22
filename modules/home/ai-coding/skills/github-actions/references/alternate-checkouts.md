## Shallow Checkout

Don't fetch full history if not needed:

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
  with:
    fetch-depth: 1 # Only fetch latest commit (default)

# Only use fetch-depth: 0 when you need full history
```

## Sparse Checkout

Only checkout paths necessary to complete a task.

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
  with:
    # package.json for dependencies, src/ for actually running the code
    sparse-checkout: |
      src/
      package.json
```
