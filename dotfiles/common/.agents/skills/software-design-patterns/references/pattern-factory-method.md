<!-- markdownlint-disable MD013 -->

# Factory Method

## Problem

A type or operation chooses which concrete product to create while callers depend on a product contract.

## Direct Shape

```ts
if (mode === "file") return new FileLogger(path);
if (mode === "http") return new HttpLogger(url);
```

## Pattern Shape

```ts
abstract class Runner {
  protected abstract createLogger(): Logger;
  run() { this.createLogger().info("start"); }
}
```

## Tests

- Each variant creates the expected product.
- Runner behavior is tested through the product contract.

## Misuse Signals

- A simple factory function would be clearer.
- Subclassing is introduced only to avoid a small, explicit selection function.
- The implementation introduces more concepts than the requirement needs.
