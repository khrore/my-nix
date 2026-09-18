<!-- markdownlint-disable MD013 -->

# Prototype

## Problem

Creating an object from scratch is expensive or complex, but a configured exemplar can be cloned safely.

## Direct Shape

```ts
const config = defaultConfig;
config.headers.Authorization = token;
return config;
```

## Pattern Shape

```ts
const config = defaultConfig.clone();
config.setHeader("Authorization", token);
return config;
```

## Tests

- Clone does not share mutable collections.
- Prototype defaults are preserved.
- Customizations affect only the clone.

## Misuse Signals

- Normal construction is clear and cheap.
- Clone copies hidden invalid state.
- The implementation introduces more concepts than the requirement needs.
