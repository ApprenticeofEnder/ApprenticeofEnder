## Cancel in Progress

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

Use only for:

- PR/branch pushes
- Workflows that don't need to complete

## Stateful Deployments

```yaml
concurrency:
  group: deploy-production
  cancel-in-progress: false
```

Use only for:

- Deployment workflows (let complete)
- Release worklfows (should never cancel)
