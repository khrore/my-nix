<!-- markdownlint-disable MD013 -->

# Law of Demeter

## Problem

Code reaches through nested collaborators or skips layers, coupling callers to internals owned elsewhere.

## Forces

- Ownership boundaries matter more than dot counts.
- Deep traversal makes internal shape public by accident.
- Simple immutable data can be fine to traverse when it is the contract.

## When to Use

- Callers navigate `service.client.config.token` or similar chains.
- A UI reads database-shaped internals.
- Scripts rely on private cache paths.
- Changing an inner object shape breaks distant callers.

## When Not to Use

- The traversed data is a public immutable DTO.
- A local transformation owns the entire data shape.
- A wrapper would only add pass-through methods.

## Implementation Shape

- Move traversal logic next to the data owner.
- Expose a narrow query or value from the boundary.
- Pass stable values instead of rich objects.
- Use facades only when they reduce real coupling.

## Pressure Example

```ts
function canRetry(context: RequestContext) {
  return context.http.client.config.retry.policy.maxAttempts > context.attempt;
}
```

## Possible Refactoring

```ts
type RetryPolicy = { allows(attempt: number): boolean };

function canRetry(policy: RetryPolicy, attempt: number) {
  return policy.allows(attempt);
}
```

## Tests

- Test retry behavior without constructing HTTP client internals.
- Verify the config owner maps nested config into `RetryPolicy`.
- Add a regression test for policy changes at the boundary.

## Misuse Signals

- Counting dots instead of ownership crossings.
- Creating pass-through wrappers for plain data.
- Hiding needed data behind an anemic facade.
