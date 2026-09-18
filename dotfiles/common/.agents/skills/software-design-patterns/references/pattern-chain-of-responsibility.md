<!-- markdownlint-disable MD013 -->

# Chain of Responsibility

## Problem

A request may be handled, transformed, or rejected by one of several ordered handlers.

## Direct Shape

```ts
if (isAdmin(req)) return admin(req);
if (hasToken(req)) return token(req);
if (isGuest(req)) return guest(req);
```

## Pattern Shape

```ts
type Handler = (req: Request) => Response | "next";

function handle(req: Request, handlers: Handler[]) {
  for (const handler of handlers) {
    const result = handler(req);
    if (result !== "next") return result;
  }
  return unauthorized();
}
```

## Tests

- Handlers run in documented order.
- The chain stops after a handler accepts.
- Fallback behavior is tested.

## Misuse Signals

- Handler order is implicit.
- A direct dispatcher is clearer.
- The implementation introduces more concepts than the requirement needs.
