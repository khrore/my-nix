<!-- markdownlint-disable MD013 -->

# Simple Factory

## Problem

Callers need one place to choose an implementation by provider, mode, type, or config.

## Direct Shape

```ts
const logger = mode === "json" ? new JsonLogger() : new TextLogger();
// repeated in many files
```

## Pattern Shape

```ts
const LOGGERS = { json: () => new JsonLogger(), text: () => new TextLogger() } as const;
function createLogger(mode: keyof typeof LOGGERS): Logger { return LOGGERS[mode](); }
```

## Tests

- Every supported choice constructs.
- Unsupported choice fails validation.
- Call sites no longer duplicate selection.

## Misuse Signals

- Factory only wraps one constructor.
- Choice logic still duplicated elsewhere.
- The implementation introduces more concepts than the requirement needs.
