<!-- markdownlint-disable MD013 -->

# Proxy

## Problem

Access to an object or service needs control such as caching, auth, lazy loading, rate limiting, or remoting.

## Direct Shape

```ts
if (!cache.has(key)) cache.set(key, await api.fetch(key));
return cache.get(key);
```

## Pattern Shape

```ts
class CachedCatalog implements Catalog {
  constructor(private inner: Catalog, private cache: Cache) {}
  async item(id: string) { return this.cache.getOrSet(id, () => this.inner.item(id)); }
}
```

## Tests

- Proxy preserves contract results.
- Added behavior such as cache hit/miss is tested.
- Failures from inner subject remain understandable.

## Misuse Signals

- Proxy hides remote or expensive behavior.
- Side effects surprise query callers.
- The implementation introduces more concepts than the requirement needs.
