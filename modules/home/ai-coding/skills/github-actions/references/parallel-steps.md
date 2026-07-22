```yaml
- run: npm ci # Faster than install
- run: npm run lint & npm run typecheck & wait # Parallel
- run: npm test
- run: npm run build
```
