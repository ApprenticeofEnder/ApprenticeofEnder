### Simple feature

```
feat: add email validation to signup form
```

### Bug fix with scope

```
fix(auth): resolve token expiration race condition
```

### Breaking change with body

```
feat(api)!: change pagination response format

The pagination response now returns `items` instead of `data` and includes
a `cursor` field for efficient pagination. The `total_count` field has been
removed in favor of `has_more`.

BREAKING CHANGE: pagination response structure has changed, clients must update
```

### Documentation change

```
docs: add API rate limiting section to README
```

### Multi-scope refactor with body

```
refactor(parser): simplify AST node creation

Replace the factory pattern with direct constructor calls. The factory
added indirection without meaningful abstraction since all node types
share the same creation logic.
```

### Revert commit

```
revert: let us never again speak of the noodle incident

Refs: 676104e, a]]215868
```

### Chore with footer

```
chore(deps): upgrade eslint to v9

Reviewed-by: Z
Refs: #456
```
