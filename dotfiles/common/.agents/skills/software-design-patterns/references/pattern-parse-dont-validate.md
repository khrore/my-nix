<!-- markdownlint-disable MD013 -->

# Parse, don’t validate

## Problem

Code checks an input invariant at a boundary, then passes along the original type. Downstream code must repeat the check
or assume the invariant holds.

## Direct Shape

```ts
function loadConfigDirs(dirs: readonly string[]): readonly string[] {
  if (dirs.length === 0) throw new Error("Expected at least one config directory");
  return dirs;
}

function initializeCache(dirs: readonly string[]) {
  const [first] = dirs;
  if (first === undefined) throw new Error("Expected at least one config directory");
  createCache(first);
}
```

## Pattern Shape

Check the invariant when converting the input to a stronger type. Have downstream functions accept that type so they
can rely on the guarantee. Use an existing domain type or schema when it already captures the invariant.

```ts
type ConfigDirs = readonly [string, ...string[]];

function parseConfigDirs(dirs: readonly string[]): ConfigDirs {
  const [first, ...rest] = dirs;
  if (first === undefined) throw new Error("Expected at least one config directory");
  return [first, ...rest];
}

function initializeCache(dirs: ConfigDirs) {
  createCache(dirs[0]);
}
```

## Tests

- Empty input fails during parsing, before any cache initialization.
- A single directory and multiple directories parse successfully and preserve their order.

## Misuse Signals

- A type assertion or unchecked constructor can bypass the invariant.
- Mutation can invalidate a guarantee after construction.
- A check depends on changing external state, such as whether the directory still exists when used.
- The stronger type adds a wrapper for an invariant that no downstream code relies on.

## Source

[Parse, don’t validate by Lexi Lambda](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
