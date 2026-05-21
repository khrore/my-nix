# Persistence Closure

## Problem

Persisted state can be loaded without the dependent context needed to make it valid.

## Forces

- Half-loaded objects fail later and misleadingly.
- Save/load should preserve operational meaning, not only shape.
- Dependencies may need versioning or clear restoration failure.

## When to Use

- A saved config omits provider, schema version, credentials reference, or feature state.
- A loaded object appears valid but cannot run.
- Migration code restores only top-level fields.
- Tests check file shape but not restored behavior.

## When Not to Use

- The dependent state is intentionally external and validated at load time.
- Persisting secrets would violate security boundaries.
- A stateless value has no dependencies.

## Implementation Shape

- Persist required non-secret dependent state.
- Load dependencies together or fail clearly.
- Version persisted formats.
- Test round trips for restored behavior.

## Problem Example

```ts
type SavedJob = { id: string; schedule: string };

function loadJob(saved: SavedJob): Job {
  return new Job(saved.id, saved.schedule, defaultRunner());
}
```

## Refactored Example

```ts
type SavedJob = { id: string; schedule: string; runnerKind: RunnerKind; version: 1 };

function loadJob(saved: SavedJob, runners: RunnerRegistry): Job {
  const runner = runners.require(saved.runnerKind);
  return new Job(saved.id, saved.schedule, runner);
}
```

## Tests

- Save/load round trip can execute the restored job.
- Missing runner kind fails at load time.
- Unsupported persisted version has a clear migration error.

## Misuse Signals

- Persisting secrets instead of references.
- Loading with silent defaults that change behavior.
- Testing serialization without restored behavior.

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
