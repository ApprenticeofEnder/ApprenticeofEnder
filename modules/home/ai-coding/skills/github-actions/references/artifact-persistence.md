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
