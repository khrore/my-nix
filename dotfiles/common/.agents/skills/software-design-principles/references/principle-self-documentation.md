<!-- markdownlint-disable MD013 -->

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

## Pressure Example

```ts
// true means charge immediately, false means save as draft
submitOrder(order, true);
```

## Possible Refactoring

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
