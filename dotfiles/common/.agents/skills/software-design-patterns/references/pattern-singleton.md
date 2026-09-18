<!-- markdownlint-disable MD013 -->

# Singleton

## Problem

Exactly one instance must coordinate a process-wide resource or identity.

## Direct Shape

```ts
export const db = new Database(process.env.DB_URL);
// imported everywhere, hard to replace in tests
```

## Pattern Shape

```ts
class DatabaseRegistry {
  private current?: Database;
  get(config: DbConfig) { return this.current ??= new Database(config.url); }
}
export const databases = new DatabaseRegistry();
```

## Tests

- Only one instance is created per intended scope.
- Tests can isolate or reset the instance.
- Configuration is explicit before first use.

## Misuse Signals

- Used as a global variable substitute.
- Explicit dependency ownership would be clearer.
- The implementation introduces more concepts than the requirement needs.
