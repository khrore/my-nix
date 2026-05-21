# Facade

## Problem

Callers must coordinate a complex subsystem or object graph to perform one goal.

## Forces

- A stable goal-oriented entrypoint reduces caller knowledge while keeping failures visible.
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

- A small API named after caller goals, backed by internal orchestration.
- Name contracts after domain capabilities rather than the pattern name.
- Keep the public interface narrow and explicit about side effects.
- Put selection and assembly at the edge of the workflow when possible.

## Problem Example

```ts
const session = auth.createSession(user);
audit.record(session);
cookies.set(session.cookie);
metrics.increment("login");
```

## Refactored Example

```ts
class LoginFacade {
  async login(user: User) {
    const session = auth.createSession(user);
    audit.record(session);
    cookies.set(session.cookie);
    metrics.increment("login");
    return session.view;
  }
}
```

## Tests

- Workflow succeeds through the facade.
- Important subsystem failures remain visible.
- Callers no longer reach around it.

## Misuse Signals

- Facade becomes a god service.
- It hides transaction or recovery boundaries.
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
