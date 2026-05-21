# DRY

## Problem

Change-prone knowledge is duplicated across code, tests, docs, config, CI, or generated outputs.

## Forces

- Duplicated rules drift under normal maintenance.
- One source of truth reduces migration and audit risk.
- Not all repeated code represents repeated knowledge.

## When to Use

- Versions, paths, schemas, defaults, or option lists appear in multiple places.
- Tests and docs encode behavior separately from code.
- Two validators enforce the same rule differently.
- Generated files are hand-edited.

## When Not to Use

- Duplication is local, small, and clearer than a shared helper.
- The similar code belongs to unrelated owners.
- A shared abstraction would hide intent or create coupling.

## Implementation Shape

- Name the knowledge that must change together.
- Put the source of truth near its owner.
- Derive validation, docs, dispatch, or generated artifacts from it.
- Add tests that catch drift.

## Problem Example

```ts
const SUPPORTED_FORMATS = ["csv", "json"];

function validateFormat(format: string) {
  return format === "csv" || format === "json" || format === "xml";
}

const helpText = "Formats: csv, json";
```

## Refactored Example

```ts
const SUPPORTED_FORMATS = ["csv", "json"] as const;
type Format = typeof SUPPORTED_FORMATS[number];

function isFormat(value: string): value is Format {
  return SUPPORTED_FORMATS.includes(value as Format);
}

const helpText = `Formats: ${SUPPORTED_FORMATS.join(", ")}`;
```

## Tests

- Verify all documented formats validate successfully.
- Verify invalid formats fail.
- Snapshot generated help text if the CLI depends on it.

## Misuse Signals

- A generic helper that obscures two unrelated workflows.
- Central constants owned by no module.
- Abstracting code shape instead of duplicated knowledge.

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
