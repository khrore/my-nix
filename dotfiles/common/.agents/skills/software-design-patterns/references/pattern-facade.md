<!-- markdownlint-disable MD013 -->

# Facade

## Problem

Callers must coordinate a complex subsystem or object graph to perform one goal.

## Direct Shape

```ts
const session = auth.createSession(user);
audit.record(session);
cookies.set(session.cookie);
metrics.increment("login");
```

## Pattern Shape

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
