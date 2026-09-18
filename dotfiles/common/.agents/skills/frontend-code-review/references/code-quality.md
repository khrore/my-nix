<!-- markdownlint-disable MD013 MD024 MD031 -->

# Review Cues — Frontend Code Quality

## Scope

Covers maintainability, type safety, component/module boundaries, state and effect correctness, styling, and tests for JavaScript, TypeScript, and framework-specific frontend code.

## Cues

### Keep component APIs explicit and stable

#### Why it matters

Components should expose clear inputs and outputs instead of relying on hidden globals, DOM queries, implicit parent structure, or framework internals. Props/inputs/events/slots/children should express the component contract.

#### Possible responses

- Use typed props/inputs and explicit events/callbacks/emits.
- Avoid reaching into parent DOM or global stores when local inputs are enough.
- Keep public component props small and cohesive.

### Keep render/template logic readable

#### Why it matters

Large render functions, templates, JSX blocks, or SFC templates that mix many conditions, loops, data mapping, and side effects are difficult to review and test.

#### Possible responses

- Extract pure formatting/mapping helpers.
- Extract cohesive child components only when they have a clear responsibility.
- Prefer early normalization of view models over deeply nested template conditionals.

### Use framework reactivity intentionally

#### Why it matters

State updates must use the framework's reactive primitives correctly. Mutating state in a way the framework cannot observe causes stale UI, missed updates, or hydration mismatches.

#### Possible responses

- React/Preact/Solid: use state setters/signals/resources instead of mutating state objects directly.
- Vue: preserve refs/reactive proxies and avoid destructuring that loses reactivity unless using `toRefs` or equivalent.
- Svelte: use assignments/stores so the compiler observes changes.
- Angular: update signals/observables/forms through their supported APIs.

### Keep effects, watchers, and subscriptions bounded

#### Why it matters

Effects/watchers/subscriptions that miss dependencies, run too often, or never clean up cause stale data, duplicate requests, memory leaks, and broken navigation behavior.

#### Possible responses

- Include all reactive dependencies or document why a value is intentionally stable.
- Clean up event listeners, intervals, observers, RxJS subscriptions, and external store subscriptions.
- Avoid doing pure derivations in effects when computed values or template expressions are enough.

### Preserve TypeScript safety at boundaries

#### Why it matters

Frontend code often consumes untrusted API, route, storage, and form data. Overusing `any`, broad casts, non-null assertions, or unchecked JSON makes runtime failures likely.

#### Possible responses

- Validate external data at API, route, storage, and form boundaries.
- Prefer `unknown` plus schema narrowing over `any` for untrusted data.
- Use discriminated unions for UI states such as loading/success/empty/error.

### Keep styling maintainable and override-friendly

#### Why it matters

Styling should follow project conventions and allow component consumers to extend or override safely. Hardcoded inline styles, duplicated class strings, or framework-specific hacks often make design changes expensive.

#### Possible responses

- Follow the repository's styling approach: CSS modules, Tailwind, scoped CSS, CSS-in-JS, design tokens, or vanilla CSS.
- Use a shared class-name utility when the project has one.
- Place consumer-provided classes/styles after defaults when project conventions expect caller overrides.
- Prefer design tokens or CSS custom properties for repeated colors, spacing, sizes, and z-index values.

### Keep browser-only code out of server/build contexts

#### Why it matters

Frameworks with SSR, SSG, server components, islands, or build-time rendering can execute modules where `window`, `document`, `localStorage`, and browser-only APIs do not exist.

#### Possible responses

- Gate browser-only code behind lifecycle hooks, client-only modules, dynamic imports, or environment checks.
- Keep server/client boundaries explicit in frameworks such as Next, Nuxt, SvelteKit, Astro, Remix, and Angular SSR.
- Avoid reading browser globals at module top level unless the file is guaranteed client-only.

### Test behavior, not implementation details

#### Why it matters

Frontend tests should verify user-visible behavior, accessibility semantics, routing outcomes, form validation, and integration side effects rather than private component internals.

#### Possible responses

- Prefer queries by role, label, text, and accessible name.
- Cover loading, empty, error, permission, and cancellation states.
- Mock network and time deterministically.
