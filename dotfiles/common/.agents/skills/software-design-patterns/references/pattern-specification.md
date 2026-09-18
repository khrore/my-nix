<!-- markdownlint-disable MD013 -->

# Specification

## Problem

Business rules or filters need to be named, reused, composed, and tested independently.

## Direct Shape

```ts
if (user.age >= 18 && user.country === "US" && !user.suspended) approve(user);
```

## Pattern Shape

```ts
const adultUsActiveUser = all(adult(), country("US"), not(suspended()));
if (adultUsActiveUser.matches(user)) approve(user);
```

## Tests

- Each rule has truth-table tests.
- Composed rules handle important combinations.
- Storage or UI details do not leak into rules.

## Misuse Signals

- Rule is used once and clearer inline.
- A generic rule engine appears too early.
- The implementation introduces more concepts than the requirement needs.
