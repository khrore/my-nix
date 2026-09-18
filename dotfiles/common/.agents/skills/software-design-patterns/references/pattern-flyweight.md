<!-- markdownlint-disable MD013 -->

# Flyweight

## Problem

Many fine-grained objects duplicate immutable intrinsic state and waste memory.

## Direct Shape

```ts
const cells = rows.map(row => new CellStyle(row.font, row.color, row.size));
```

## Pattern Shape

```ts
class StylePool {
  private styles = new Map<string, CellStyle>();
  get(key: StyleKey) {
    return this.styles.get(key.id) ?? this.styles.set(key.id, new CellStyle(key)).get(key.id)!;
  }
}
```

## Tests

- Equivalent keys return the same shared style.
- Extrinsic state is not stored in the flyweight.
- Memory-sensitive path preserves behavior.

## Misuse Signals

- Object count is small.
- Shared state is mutable.
- The implementation introduces more concepts than the requirement needs.
