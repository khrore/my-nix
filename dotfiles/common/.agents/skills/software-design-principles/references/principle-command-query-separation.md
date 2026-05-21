# Command-Query Separation

## Problem

A callable looks like a read but mutates state, or looks like a command but hides important reads.

## Forces

- Read/write separation improves tests, caching, retries, and dry runs.
- Some operations must combine read and write for atomicity.
- Names should reveal side effects.

## When to Use

- A `get` method refreshes caches or writes files.
- A `validate` command fixes data.
- A CLI check mutates configuration unless a flag is set.
- Tests are flaky because reads alter global state.

## When Not to Use

- The operation must be atomic under locking or uniqueness constraints.
- A command returns a status, id, or summary without hidden reads.
- Splitting would make consistency weaker.

## Implementation Shape

- Split into pairs like `plan/apply`, `validate/fix`, `check/write`, or `render/persist`.
- Name combined operations explicitly.
- Document atomicity exceptions at the boundary.

## Problem Example

```ts
function getUser(id: UserId): User {
  const user = db.users.find(id);
  db.audit.write("read-user", id);
  cache.set(id, user);
  return user;
}
```

## Refactored Example

```ts
function findUser(id: UserId): User {
  return db.users.find(id);
}

function recordUserRead(id: UserId) {
  db.audit.write("read-user", id);
}
```

## Tests

- Calling `findUser` does not write audit or cache state.
- Calling `recordUserRead` writes the expected audit event.
- Combined flows call both operations explicitly.

## Misuse Signals

- Splitting atomic reservation operations.
- Forbidding command result summaries.
- Renaming side-effectful reads without changing behavior.

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
