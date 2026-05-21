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

## Problem Example

```ts
function canRetry(context: RequestContext) {
  return context.http.client.config.retry.policy.maxAttempts > context.attempt;
}
```

## Refactored Example

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

## Review Checklist

- Can you name the design pressure without naming the principle?
- Does the proposed change reduce real coupling, drift, surprise, or invalid state?
- Is the smallest useful boundary visible in names, types, or module layout?
- Are validation and failure behavior explicit at the edge where callers enter?
- Does the refactor preserve current behavior while making the next change safer?
- Would an ordinary maintainer know where to make the next related edit?

## Refactoring Moves

- Start with a narrow local change before introducing a broad abstraction.
- Move knowledge to the owner that already maintains the relevant invariant.
- Prefer explicit parameters, small helpers, and named value objects before frameworks.
- Add tests around the behavior that was hard to reason about before the refactor.
- Keep compatibility at public boundaries unless the task explicitly includes migration.

## Example Reading Guide

- The problem example shows the smell to recognize in real code.
- The refactored example shows one possible shape, not the only valid implementation.
- Translate classes, interfaces, and modules into the host language's natural units.
- Preserve local conventions when they already solve the same problem clearly.
