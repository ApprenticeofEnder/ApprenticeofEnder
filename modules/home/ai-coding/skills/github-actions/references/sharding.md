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
