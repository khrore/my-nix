# Design by Contract

## Problem

Inputs, outputs, invariants, side effects, or failure modes are implicit at a public boundary.

## Forces

- Invalid states are cheapest to reject before side effects.
- Adapters and variants must preserve the same guarantees.
- Executable contracts are stronger than comments.

## When to Use

- A function writes before validating input.
- Callers guess whether null, empty, or partial values are allowed.
- Adapters fail differently for the same contract.
- A refactor can break invariants silently.

## When Not to Use

- Internal calls are already protected by a validated boundary.
- The type system fully encodes the constraint.
- Repeated runtime checks would add noise without extra safety.

## Implementation Shape

- Validate preconditions at the boundary.
- Encode invariants with types, schemas, assertions, or guard clauses.
- Define deterministic failure behavior.
- Test postconditions and important invalid cases.

## Problem Example

```ts
async function createAccount(input: AccountInput) {
  await audit.write("create-account");
  return db.accounts.insert({ email: input.email.toLowerCase(), plan: input.plan });
}
```

## Refactored Example

```ts
function parseAccount(input: AccountInput): AccountDraft {
  if (!input.email.includes("@")) throw new ValidationError("email");
  if (!PLANS.includes(input.plan)) throw new ValidationError("plan");
  return { email: input.email.toLowerCase(), plan: input.plan };
}

async function createAccount(input: AccountInput) {
  const draft = parseAccount(input);
  await audit.write("create-account");
  return db.accounts.insert(draft);
}
```

## Tests

- Invalid email fails before audit and database writes.
- Unsupported plan returns the documented error.
- Successful create stores normalized email.

## Misuse Signals

- Contracts documented only in comments.
- Validation duplicated deep inside every helper.
- Adapters that throw incompatible errors.

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
