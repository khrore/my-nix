<!-- markdownlint-disable MD013 -->

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

## Pressure Example

```ts
type SavedJob = { id: string; schedule: string };

function loadJob(saved: SavedJob): Job {
  return new Job(saved.id, saved.schedule, defaultRunner());
}
```

## Possible Refactoring

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
