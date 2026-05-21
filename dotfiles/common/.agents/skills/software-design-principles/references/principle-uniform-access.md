# Uniform Access

## Problem

Callers must care whether a value is stored, computed, fetched, generated, or cached.

## Forces

- Stable calling patterns reduce churn as implementations evolve.
- Similar capabilities should be accessed similarly.
- Expensive or side-effectful access still needs clear naming.

## When to Use

- Some settings are fields while related settings require service calls.
- A cached value and computed value have incompatible APIs.
- Callers branch on storage details.
- Implementation changes force broad call-site rewrites.

## When Not to Use

- Hiding expensive remote calls behind property-like access.
- Pretending mutating operations are reads.
- Flattening genuinely different capabilities into one vague method.

## Implementation Shape

- Expose a consistent method or command shape for similar capabilities.
- Hide incidental storage and computation details.
- Keep cost and side effects visible in names when relevant.

## Problem Example

```ts
const timeout = config.timeoutMs;
const retries = config.getRetryPolicy().maxRetries;
const region = await configStore.fetchRegion();
```

## Refactored Example

```ts
interface RuntimeConfig {
  getNumber(key: "timeoutMs" | "maxRetries"): number;
  getString(key: "region"): Promise<string>;
}
```

## Tests

- Callers do not branch on where config values come from.
- Stored and computed values follow the same access contract.
- Remote or async access remains explicit.

## Misuse Signals

- Masking remote calls as cheap fields.
- One generic accessor that erases types.
- Uniformity that hides important failure modes.

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
