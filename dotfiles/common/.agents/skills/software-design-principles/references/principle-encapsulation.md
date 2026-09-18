<!-- markdownlint-disable MD013 -->

# Encapsulation

## Problem

Callers depend on internal state, private paths, cache files, incidental defaults, or mutation rules they do not own.

## Forces

- State should live with operations that maintain its invariants.
- Stable interfaces let internals change.
- Exposing too much surface area invites invalid mutations.

## When to Use

- Tests or callers write private fields directly.
- Config consumers rely on undocumented defaults.
- A module exports mutable collections it owns.
- Callers know cache file names or internal object shape.

## When Not to Use

- A value object is intentionally transparent.
- A getter adds no stability, validation, or abstraction.
- A stable test helper is clearer than a broad production API.

## Implementation Shape

- Reduce exported surface area.
- Move mutation behind operations that enforce invariants.
- Return copies or immutable views when needed.
- Make required configuration explicit.

## Pressure Example

```ts
class Cart {
  items: CartItem[] = [];
  total = 0;
}

cart.items.push(item);
cart.total += item.price;
```

## Possible Refactoring

```ts
class Cart {
  private items: CartItem[] = [];

  add(item: CartItem) {
    if (item.quantity <= 0) throw new Error("quantity");
    this.items.push(item);
  }

  total() { return this.items.reduce((sum, item) => sum + item.price, 0); }
}
```

## Tests

- Adding invalid item is rejected.
- Total is derived from items and cannot drift.
- Callers cannot mutate internal items directly.

## Misuse Signals

- Getter/setter layers that expose the same mutable state.
- Hiding simple public DTO fields.
- Exposing internals just to simplify tests.
