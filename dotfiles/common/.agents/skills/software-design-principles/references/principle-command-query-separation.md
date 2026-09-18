<!-- markdownlint-disable MD013 -->

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

## Pressure Example

```ts
function getUser(id: UserId): User {
  const user = db.users.find(id);
  db.audit.write("read-user", id);
  cache.set(id, user);
  return user;
}
```

## Possible Refactoring

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
- Separating a required audit or policy check so callers can accidentally omit it.
- Forbidding command result summaries.
- Renaming side-effectful reads without changing behavior.
