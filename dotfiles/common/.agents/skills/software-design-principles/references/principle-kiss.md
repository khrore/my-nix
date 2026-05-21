# KISS

## Problem

The implementation is harder to inspect, debug, or repair than the requirement justifies.

## Forces

- Simple designs fail in obvious places.
- Extra layers create hidden behavior and ownership ambiguity.
- A small abstraction can still be justified when it removes real complexity.

## When to Use

- A generator, hook, framework, or registry handles a small fixed case.
- Control flow crosses code, templates, scripts, and config without one owner.
- Special cases accumulate around unnormalized inputs.
- Meta-programming hides simple data transformation.

## When Not to Use

- A boundary protects a real invariant, security rule, transaction, or dependency direction.
- A small helper clearly removes drift.
- The local framework convention is simple for maintainers.

## Implementation Shape

- Normalize inputs early.
- Use direct data flow and explicit dependencies.
- Collapse layers that do not reduce complexity.
- Prefer boring language constructs before clever automation.

## Problem Example

```ts
const pipeline = createPipeline()
  .use(resolveModeFromEnv())
  .use(registerDefaultTransforms())
  .use(dynamicStepLoader("./steps"));

export const result = pipeline.execute({ value: "42" });
```

## Refactored Example

```ts
function normalizeValue(input: string): number {
  const value = Number(input);
  if (!Number.isFinite(value)) throw new Error("value must be numeric");
  return value;
}

export const result = normalizeValue("42");
```

## Tests

- Test the direct function for valid and invalid input.
- Verify removed layers had no behavior that needs replacement.
- Add a regression test for the actual requirement, not the old mechanism.

## Misuse Signals

- Using KISS to remove necessary validation.
- Rejecting an abstraction that protects a volatile dependency.
- Inlining everything until ownership becomes unclear.

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
