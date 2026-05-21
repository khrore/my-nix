# Principle of Least Astonishment

## Problem

Names, defaults, flags, config keys, syntax, or side effects violate local expectations.

## Forces

- Predictable interfaces reduce documentation burden.
- Similar shapes should mean similar things.
- Risky behavior should be explicit.

## When to Use

- A `--check` flag writes files.
- A default depends silently on cwd or env vars.
- Similar config keys have different semantics.
- An operation name understates blast radius.

## When Not to Use

- A stable public API needs a migration path before renaming.
- Unusual behavior is required by an external standard.
- A local convention intentionally differs and is documented.

## Implementation Shape

- Align names with actual behavior.
- Make risky behavior opt in.
- Surface hidden context.
- Keep CLI help, schemas, docs, and generated outputs synchronized.

## Problem Example

```ts
// Users expect this to only report differences.
runTool(["format", "--check"]); // rewrites files and exits 0
```

## Refactored Example

```ts
runTool(["format", "--check"]); // read-only, nonzero on differences
runTool(["format", "--write"]); // explicit mutation
```

## Tests

- `--check` leaves files unchanged.
- `--write` changes files when formatting is needed.
- Help text documents the distinction.

## Misuse Signals

- Renaming public APIs without compatibility.
- Hiding required unusual behavior.
- Changing defaults without migration notes.

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
