# Self-Documentation

## Problem

Comments carry intent that names, types, structure, or tests should make visible.

## Forces

- Comments drift; executable structure is checked by tools and tests.
- Good names reduce the need for procedural explanation.
- Some constraints still require comments.

## When to Use

- A comment explains what a vague variable means.
- A long function needs comments to mark phases.
- Boolean flags make calls unreadable.
- Examples and defaults are far from the code they describe.

## When Not to Use

- A comment explains an external requirement, performance constraint, or historical trap.
- A named extraction would fragment a clear short function.
- Public docs are needed for consumers.

## Implementation Shape

- Rename vague identifiers.
- Extract meaningful functions or values.
- Use types for domain concepts.
- Keep comments for why, constraints, and tradeoffs.

## Problem Example

```ts
// true means charge immediately, false means save as draft
submitOrder(order, true);
```

## Refactored Example

```ts
type SubmitMode = "charge-now" | "save-draft";

submitOrder(order, { mode: "charge-now" satisfies SubmitMode });
```

## Tests

- Call sites read clearly without nearby comments.
- Domain-specific types reject invalid modes.
- Important constraints remain documented where code cannot express them.

## Misuse Signals

- Deleting useful why-comments.
- Extracting every line into a named function.
- Using long names to compensate for poor structure.

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
