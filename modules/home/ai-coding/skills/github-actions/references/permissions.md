Quick reference for GitHub Actions permissions.

```yaml
permissions:
  contents: write # For pushing commits/tags
  pull-requests: write # For PR comments
  issues: write # For issue comments
  packages: write # For publishing packages
  deployments: write # For deployments
  id-token: write # OIDC token for cloud auth
```

**Debug:**

```yaml
- name: Check token permissions
  run: |
    curl -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
         https://api.github.com/repos/${{ github.repository }}
```

### Job-level permissions (override workflow-level)

```yaml
permissions:
  contents: read

jobs:
  deploy:
    permissions:
      contents: write
      deployments: write
```
