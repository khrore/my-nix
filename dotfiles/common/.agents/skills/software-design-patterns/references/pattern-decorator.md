<!-- markdownlint-disable MD013 -->

# Decorator

## Problem

Behavior must be added around an object while preserving its core contract.

## Direct Shape

```ts
class RetryingClient extends HttpClient {
  async get(url: string) { /* duplicates base behavior with retry */ }
}
```

## Pattern Shape

```ts
class RetryingHttpClient implements HttpClient {
  constructor(private inner: HttpClient) {}
  async get(url: string) { return retry(() => this.inner.get(url)); }
}
```

## Tests

- Decorator preserves the contract.
- Added behavior such as retry or logging is tested.
- Failure propagation remains documented.

## Misuse Signals

- Deep wrapper stacks obscure flow.
- Decorator subtly changes return semantics.
- The implementation introduces more concepts than the requirement needs.
