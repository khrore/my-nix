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

## Problem Example

```ts
class Cart {
  items: CartItem[] = [];
  total = 0;
}

cart.items.push(item);
cart.total += item.price;
```

## Refactored Example

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
