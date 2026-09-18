<!-- markdownlint-disable MD013 -->

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

## Pressure Example

```ts
const pipeline = createPipeline()
  .use(resolveModeFromEnv())
  .use(registerDefaultTransforms())
  .use(dynamicStepLoader("./steps"));

export const result = pipeline.execute({ value: "42" });
```

## Possible Refactoring

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
