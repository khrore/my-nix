<!-- markdownlint-disable MD013 -->

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

## Pressure Example

```ts
// Users expect this to only report differences.
runTool(["format", "--check"]); // rewrites files and exits 0
```

## Possible Refactoring

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
