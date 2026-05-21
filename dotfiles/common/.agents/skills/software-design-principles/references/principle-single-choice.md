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

## Problem Example

```ts
const cliProviders = ["openai", "local"];
const docs = "providers: openai, local, mock";

function createProvider(name: string) {
  if (name === "openai") return new OpenAIProvider();
  if (name === "anthropic") return new AnthropicProvider();
}
```

## Refactored Example

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

## Review Checklist

- Can you name the design pressure without naming the principle?
- Does the proposed change reduce real coupling, drift, surprise, or invalid state?
- Is the smallest useful boundary visible in names, types, or module layout?
- Are validation and failure behavior explicit at the edge where callers enter?
- Does the refactor preserve current behavior while making the next change safer?
- Would an ordinary maintainer know where to make the next related edit?

## Refactoring Moves

- Start with a narrow local change before introducing a broad abstraction.
- Move knowledge to the owner that already maintains the relevant invariant.
- Prefer explicit parameters, small helpers, and named value objects before frameworks.
- Add tests around the behavior that was hard to reason about before the refactor.
- Keep compatibility at public boundaries unless the task explicitly includes migration.

## Example Reading Guide

- The problem example shows the smell to recognize in real code.
- The refactored example shows one possible shape, not the only valid implementation.
- Translate classes, interfaces, and modules into the host language's natural units.
- Preserve local conventions when they already solve the same problem clearly.
