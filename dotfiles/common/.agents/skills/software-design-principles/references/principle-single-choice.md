<!-- markdownlint-disable MD013 -->

# Single Choice

## Problem

Supported modes, variants, providers, feature flags, or enum-like options are duplicated across the codebase.

## Forces

- Split choice logic drifts.
- Unsupported combinations appear when validation, dispatch, docs, and tests disagree.
- A readable authoritative map can be simpler than a registry.

## When to Use

- Provider names appear in CLI parsing, docs, dispatch, and tests separately.
- Adding a mode requires editing many switch statements.
- Validation allows choices that dispatch cannot handle.
- Feature flags are interpreted differently by layers.

## When Not to Use

- A local two-case branch is the only consumer.
- A registry hides a small authoritative map.
- Different bounded contexts intentionally use different option sets.

## Implementation Shape

- Keep the exhaustive list in one source.
- Derive labels, validation, dispatch, docs, and tests from that source where practical.
- Centralize mode selection at a clear boundary.

## Pressure Example

```ts
const cliProviders = ["openai", "local"];
const docs = "providers: openai, local, mock";

function createProvider(name: string) {
  if (name === "openai") return new OpenAIProvider();
  if (name === "anthropic") return new AnthropicProvider();
}
```

## Possible Refactoring

```ts
const PROVIDERS = {
  openai: () => new OpenAIProvider(),
  local: () => new LocalProvider(),
} as const;

type ProviderName = keyof typeof PROVIDERS;
const providerDocs = Object.keys(PROVIDERS).join(", ");
```

## Tests

- Every documented provider can be constructed.
- Unsupported provider names fail validation.
- Adding a provider changes one authoritative map.

## Misuse Signals

- Global registries with unclear ownership.
- Centralizing choices that belong to different contexts.
- Duplicating the source of truth in generated files without checks.
