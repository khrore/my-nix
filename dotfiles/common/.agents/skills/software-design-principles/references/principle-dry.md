<!-- markdownlint-disable MD013 -->

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

## Pressure Example

```ts
const SUPPORTED_FORMATS = ["csv", "json"];

function validateFormat(format: string) {
  return format === "csv" || format === "json" || format === "xml";
}

const helpText = "Formats: csv, json";
```

## Possible Refactoring

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
