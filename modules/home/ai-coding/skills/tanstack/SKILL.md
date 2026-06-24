---
name: tanstack
description: "Use when: reviewing PRs that add or change TanStack Query, TanStack Router, TanStack Start, server functions, loaders, mutations, query keys, SSR hydration, or Router/Query integration."
---

# TanStack PR Review

Use this skill when a pull request adds or changes TanStack Query, TanStack Router, TanStack Start, or their SSR integration points. Focus on review findings, bug risks, and missing safeguards. Do not turn the review into a tutorial.

## 1. When to Apply

Apply this skill when the diff includes TanStack usage such as:

- Imports from `@tanstack/react-query`, `@tanstack/react-router`, `@tanstack/start`, or nearby TanStack integration helpers.
- Query APIs like `useQuery`, `useSuspenseQuery`, `useInfiniteQuery`, `useMutation`, `queryOptions`, `infiniteQueryOptions`, `invalidateQueries`, or `setQueryData`.
- Router APIs like `createRouter`, `createFileRoute`, `createRootRoute`, `Link`, route loaders, `validateSearch`, and route middleware or guards.
- Start APIs like `createServerFn`, server loaders, server actions, session or auth helpers, or request handling tied to Start.
- SSR wiring such as `setupRouterSsrQueryIntegration`, dehydration and hydration setup, route preloading, or cache coordination between Router and Query.

If the PR mixes TanStack with framework-specific wrappers, review the TanStack contract underneath rather than only the wrapper surface.

## 2. Code Review Checklist

Check these items first:

- `qk-array-structure`: Query keys are arrays, never strings or plain objects.
- `qk-include-dependencies`: Every value used by `queryFn` is represented in the query key.
- `ts-register-router`: Router types are registered globally so route inference works.
- `load-ensure-query-data`: Loaders use `queryClient.ensureQueryData()` when loading query-backed data.
- `search-validation`: Search params are validated with a schema.
- `sf-input-validation`: Every server function validates its input.
- `mut-invalidate-queries`: Mutations invalidate or update related cached queries.
- `err-error-boundaries`: Query-driven UI has error boundaries and reset handling.

## 3. CRITICAL Rules

Flag violations in this section as bugs, not suggestions.

### TanStack Query - Query Keys

#### `qk-array-structure`

Query keys must be arrays.

Bad:

```ts
useQuery({
  queryKey: 'todos',
  queryFn: fetchTodos,
})
```

Good:

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})
```

#### `qk-include-dependencies`

Every variable read by `queryFn` must appear in the key. Missing dependencies create stale-data and cache-collision bugs.

Bad:

```ts
useQuery({
  queryKey: ['user'],
  queryFn: () => fetchUser(userId),
})
```

Good:

```ts
useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})
```

#### `qk-hierarchical-organization`

Keys should move from general to specific, for example `['entity', id, 'sub-resource', { filters }]`. Flag flat or inconsistent structures that make invalidation imprecise.

#### `qk-factory-pattern`

In apps with many query types, repeated ad-hoc key construction is a maintainability risk. Flag missing key factories when the PR expands an already-large key surface.

#### `qk-serializable`

All key parts must be JSON-serializable. Flag functions, class instances, `Date`, `Map`, `Set`, or custom objects with unstable identity.

### TanStack Query - Caching

#### `cache-stale-time`

Review whether `staleTime` matches the data volatility. The default `0` causes refetch-on-mount behavior and is often an accidental perf bug.

#### `cache-gc-time`

Review `gcTime` for inactive-query retention. Missing or mismatched values can cause unnecessary refetch churn or stale memory retention.

### TanStack Router - Type Safety

#### `ts-register-router`

Router types must be registered globally for end-to-end type inference. Missing registration is a correctness issue because route APIs silently lose type safety.

Bad:

```ts
const router = createRouter({ routeTree })
```

Good:

```ts
const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
```

### TanStack Router - Route Organization

#### `org-file-based-routing`

Follow file-based routing conventions. Flag route definitions that bypass the expected route-tree structure without a strong reason, because they weaken discoverability and route inference.

### TanStack Start - Server Functions

#### `sf-create-server-fn`

Use `createServerFn` correctly. Flag server-side logic that bypasses Start's server-function model when the route expects that contract.

#### `sf-input-validation`

All server function inputs must be validated before use. Treat missing validation as a security bug.

Bad:

```ts
export const updateUser = createServerFn({ method: 'POST' })
  .handler(async ({ data }) => updateUserInDb(data.id, data.role))
```

Good:

```ts
const updateUserInput = z.object({
  id: z.string().uuid(),
  role: z.enum(['admin', 'editor', 'viewer']),
})

export const updateUser = createServerFn({ method: 'POST' })
  .validator(updateUserInput)
  .handler(async ({ data }) => updateUserInDb(data.id, data.role))
```

### TanStack Start - Security

Treat these as mandatory review checks:

- All server-function inputs are validated.
- Auth-sensitive server functions verify caller identity and authorization.
- CSRF protections are present where mutation-like requests rely on cookies or session auth.
- No secrets, tokens, or privileged server-only data leak into client bundles, serialized loader data, or route context.

### TanStack Integration - SSR

#### `ssr-dehydrate-hydrate`

When Router and Query are used together with SSR, prefer `setupRouterSsrQueryIntegration` so dehydration and hydration stay automatic and consistent. Flag manual SSR cache wiring that duplicates or conflicts with the supported integration path.

## 4. HIGH Priority Rules

Strongly recommend fixes here. These are common sources of production defects.

### Mutations

#### `mut-invalidate-queries`

Mutations should invalidate or directly update related queries after success.

Bad:

```ts
useMutation({
  mutationFn: saveTodo,
})
```

Good:

```ts
useMutation({
  mutationFn: saveTodo,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

#### `mut-optimistic-updates`

If the PR uses optimistic updates, confirm rollback logic exists on error and that concurrent mutations do not leave cache state corrupted.

#### `mut-error-handling`

Mutation failures should surface clearly to users and should not leave stale optimistic state or silent failure paths.

### Error Handling

#### `err-error-boundaries`

Query-dependent UI should use error boundaries, including `useQueryErrorResetBoundary` where retry/reset flow matters. Flag crashes, stuck fallback screens, or retry paths that never reset the boundary.

#### `err-retry-logic`

Retry policy should match the operation. Flag aggressive retries for validation or auth failures, and missing retries for transient network failures where resilience is expected.

### Data Loading (Router)

#### `load-ensure-query-data`

Loaders should use `queryClient.ensureQueryData()`, not `prefetchQuery()`, when the route needs the data or should fail on load errors.

Bad:

```ts
loader: () => queryClient.prefetchQuery(todosQueryOptions)
```

Good:

```ts
loader: () => queryClient.ensureQueryData(todosQueryOptions)
```

Flag direct `fetch()` calls in loaders when the same resource is already modeled as a Query cache entry. That bypasses the cache and splits the source of truth.

#### `search-validation`

Search params must be validated with a schema. Flag routes that trust raw search params, especially when values drive server requests, filtering, pagination, or auth-sensitive behavior.

### Authentication (Start)

#### `auth-sessions`

Review session management for secure cookie settings, expiration handling, and clear server-side ownership of auth state.

#### `auth-route-protection`

Protected routes should verify auth in middleware, loaders, or server-side boundaries. Flag client-only auth checks that can be bypassed during server rendering or direct navigation.

## 5. MEDIUM Priority Rules

Raise these as improvements unless the PR context makes them more severe.

### Performance

#### `perf-select-transform`

Use `select` to derive computed values from cached data instead of recomputing in many consumers. Flag repeated transformation logic that causes unnecessary rerenders or duplicated derivation code.

#### `perf-structural-sharing`

Leverage structural sharing. Flag updates that recreate large nested objects unnecessarily and defeat referential stability.

#### `query-cancellation`

Pass `AbortSignal` through query-backed fetch calls so cancelled navigations and stale requests do not keep running.

Bad:

```ts
queryFn: () => fetch('/api/todos').then((r) => r.json())
```

Good:

```ts
queryFn: ({ signal }) => fetch('/api/todos', { signal }).then((r) => r.json())
```

### Navigation

Review whether active navigation state uses TanStack Router's `Link` features rather than custom URL matching that can drift from router behavior.

Review whether intent-based preloading is used appropriately with `preload="intent"` or equivalent router support when it improves perceived latency without over-fetching.

### Caching Coordination (Integration)

#### `cache-single-source`

When Router and Query are both present, Query should usually be the single cache source for data. Review `defaultPreloadStaleTime: 0` and related settings so Router preloading does not create a second competing freshness model.

## 6. Common Anti-Patterns to Flag

Flag these patterns explicitly when they appear:

- Using `prefetchQuery` in loaders when the route needs data or should fail on errors.
- String query keys instead of array keys.
- Missing query-key dependencies for values used in `queryFn`.
- Direct fetches in loaders that bypass an existing Query cache model.
- Query-driven UI without error boundaries.
- Server functions without input validation.
- Unvalidated search params.
- Non-JSON values in query keys.
- Mutations that do not invalidate or reconcile related cached queries.
- Router cache and Query cache both controlling freshness without explicit coordination.

## 7. Review Priority

When reviewing TanStack code in a PR, prioritize findings in this order:

1. Security first: server-function validation, auth checks, CSRF exposure, secret leakage.
2. Correctness: query-key shape, dependency completeness, cache invalidation, loader/query coordination.
3. Reliability: error boundaries, retry behavior, rollback safety, SSR hydration consistency.
4. Performance: `staleTime`, `gcTime`, `select`, cancellation, preload strategy.
5. Maintainability: key factories, hierarchical key organization, router type registration, file-based routing discipline.

Prefer a smaller number of high-confidence review comments over broad framework commentary. If a violation can lead to stale data, lost type safety, security exposure, hydration bugs, or broken invalidation, treat it as a concrete bug and say so plainly.