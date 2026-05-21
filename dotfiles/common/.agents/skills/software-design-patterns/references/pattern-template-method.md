# Template Method

## Problem

A workflow has fixed steps but some steps vary in subclasses.

## Forces

- The invariant algorithm order is owned by the base type while variants provide specific steps.
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

- A base method defines the skeleton and calls narrowly scoped overridable steps.
- Name contracts after domain capabilities rather than the pattern name.
- Keep the public interface narrow and explicit about side effects.
- Put selection and assembly at the edge of the workflow when possible.

## Problem Example

```ts
class CsvImporter { async run() { await read(); parseCsv(); validate(); save(); } }
class JsonImporter { async run() { await read(); parseJson(); validate(); save(); } }
```

## Refactored Example

```ts
abstract class Importer {
  async run() { const raw = await this.read(); const rows = this.parse(raw); validate(rows); await save(rows); }
  protected abstract read(): Promise<string>;
  protected abstract parse(raw: string): Row[];
}
```

## Tests

- Workflow order is fixed and tested once.
- Each hook is tested by variant.
- Subclass cannot skip required validation.

## Misuse Signals

- Inheritance is only for reuse.
- Composition would express variable steps more clearly.
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
