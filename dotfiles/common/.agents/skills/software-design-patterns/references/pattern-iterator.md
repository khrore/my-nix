# Iterator

## Problem

Consumers need sequential access without depending on collection internals.

## Forces

- Traversal order and pagination should be owned by the collection or source.
- The pattern should make the design pressure explicit, not merely add vocabulary.
- Construction, selection, and failure behavior should remain easy to find.
- Prefer the smallest form of the pattern that protects the boundary or variation point.

## When to Use

- The pressure exists in current requirements, not only speculative future work.
- A plain function, local conditional, or direct constructor would duplicate knowledge or leak details.
- Callers become simpler, safer, or easier to test through the pattern contract.
- There is a clear owner for assembly or selection.

## When Not to Use

- The problem has one stable implementation and no useful fake or boundary.
- The pattern makes control flow, state, or errors harder to inspect.
- The abstraction name is clearer than the domain capability it represents.
- A local helper or direct data structure solves the problem cleanly.

## Implementation Shape

- An iterator or iterable interface that yields values and hides traversal details.
- Name contracts after domain capabilities rather than the pattern name.
- Keep the public interface narrow and explicit about side effects.
- Put selection and assembly at the edge of the workflow when possible.

## Problem Example

```ts
for (let i = 0; i < store.pages.length; i++) {
  for (const item of store.pages[i].items) consume(item);
}
```

## Refactored Example

```ts
for await (const item of store.items()) {
  consume(item);
}
```

## Tests

- Traversal returns all items in order.
- Pagination or internal shape can change without caller changes.

## Misuse Signals

- The collection is a simple public array.
- Iterator hides expensive remote calls without async naming.
- The implementation introduces more concepts than the requirement needs.

## Review Checklist

- What exact variation, boundary, lifecycle, or construction pressure exists now?
- Which caller becomes simpler or safer after introducing the pattern?
- What simpler construct was considered first, and why is it insufficient?
- Where does construction, selection, or assembly happen?
- What contract must every implementation preserve?
- Which tests prove the pattern is helping rather than hiding behavior?

## Refactoring Moves

- First isolate the behavior behind a small domain-named function or interface.
- Move selection logic to one obvious composition point.
- Keep external SDK, storage, or transport types out of inner policy contracts.
- Add one implementation at a time and test it through the shared contract.
- Remove pattern scaffolding if no current variation or boundary remains.

## Example Reading Guide

- The problem example shows the pressure that makes the pattern tempting.
- The refactored example shows a minimal shape, not a framework prescription.
- Rename pattern-shaped types to domain capabilities in production code.
- Prefer composition unless the local language or framework makes another shape simpler.
