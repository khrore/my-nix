<!-- markdownlint-disable MD013 -->

# Iterator

## Problem

Consumers need sequential access without depending on collection internals.

## Direct Shape

```ts
for (let i = 0; i < store.pages.length; i++) {
  for (const item of store.pages[i].items) consume(item);
}
```

## Pattern Shape

```ts
for await (const item of store.items()) {
  consume(item);
}
```

## Tests

- Traversal returns all items in order.
- Pagination or internal shape can change without caller changes.

## Misuse Signals

- The collection is a simple public array.
- Iterator hides expensive remote calls without async naming.
- The implementation introduces more concepts than the requirement needs.
