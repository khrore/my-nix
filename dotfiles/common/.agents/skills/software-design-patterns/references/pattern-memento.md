<!-- markdownlint-disable MD013 -->

# Memento

## Problem

An object state must be captured and restored without exposing internals.

## Direct Shape

```ts
history.push(JSON.stringify(editor as any));
Object.assign(editor, JSON.parse(history.pop()));
```

## Pattern Shape

```ts
const snapshot = editor.save();
history.push(snapshot);
editor.restore(history.pop());
```

## Tests

- Snapshot restore returns to previous behavior.
- Snapshot does not expose mutable internals.
- Invalid snapshot version fails clearly.

## Misuse Signals

- Persisting whole private state leaks secrets.
- A simple command undo is more precise.
- The implementation introduces more concepts than the requirement needs.
