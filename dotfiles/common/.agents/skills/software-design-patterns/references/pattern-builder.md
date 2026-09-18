<!-- markdownlint-disable MD013 -->

# Builder

## Problem

Constructing a complex value requires readable steps, defaults, validation, or many optional settings.

## Direct Shape

```ts
const request = { url, timeout: 0, retries: -1, headers: null };
client.send(request);
```

## Pattern Shape

```ts
const request = RequestBuilder.to(url)
  .timeoutMs(5000)
  .retries(3)
  .header("Accept", "application/json")
  .build();
client.send(request);
```

## Tests

- Required fields are enforced.
- Invalid combinations fail at build.
- Defaults are applied predictably.

## Misuse Signals

- Plain record with two fields.
- Builder permits invalid final objects.
- The implementation introduces more concepts than the requirement needs.
