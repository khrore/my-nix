<!-- markdownlint-disable MD013 -->

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

## Pressure Example

```ts
const timeout = config.timeoutMs;
const retries = config.getRetryPolicy().maxRetries;
const region = await configStore.fetchRegion();
```

## Possible Refactoring

```ts
interface RuntimeConfig {
  timeoutMs(): number;
  maxRetries(): number;
  region(): Promise<string>;
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
