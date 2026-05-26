<!-- markdownlint-disable MD013 MD024 MD031 -->

# Rule Catalog — Framework-Specific Frontend Cues

## Scope

Covers review cues that depend on common JavaScript and TypeScript frontend frameworks. Apply only the sections matching the files under review.

## React, Preact, Next, and Remix

- Check hook rules: hooks are called unconditionally and dependencies are correct.
- Keep server/client boundaries explicit in Next, Remix, and React Server Components.
- Avoid stale closures in callbacks, effects, subscriptions, timers, and event handlers.
- Use stable keys for lists; do not use indexes when item order can change.
- Avoid context values that recreate large objects every render unless consumers are intended to update.
- Treat `useMemo` and `useCallback` as targeted tools, not mandatory for every inline value.

## Vue and Nuxt

- Preserve reactivity when destructuring props, refs, and reactive objects.
- Use computed values for pure derivations instead of watchers.
- Clean up watchers, event listeners, intervals, and external subscriptions.
- Keep Nuxt server/client-only code in the appropriate plugin, composable, or lifecycle boundary.
- Validate `v-html` usage and sanitize trusted content.

## Svelte and SvelteKit

- Ensure reactive statements do not trigger loops or hide side effects.
- Use stores or assignments so state changes are observed by the compiler.
- Keep browser-only APIs out of server `load` functions and module scope unless guarded.
- Clean up actions, intervals, observers, and subscriptions on destroy.
- Validate `{@html}` usage and sanitize trusted content.

## Angular

- Prefer typed reactive forms or well-scoped template-driven forms with clear validation.
- Manage RxJS subscriptions with `async` pipe, `takeUntilDestroyed`, signals, or other lifecycle-safe patterns.
- Avoid expensive methods in templates when they run on every change-detection pass.
- Keep services responsible for data access and orchestration; keep components focused on presentation and interaction.
- Avoid bypassing Angular sanitization unless the trusted source and sanitizer are explicit.

## Solid and SolidStart

- Use signals, memos, and resources in a way that preserves fine-grained reactivity.
- Avoid destructuring props in a way that loses tracking.
- Keep effects for side effects, not pure derivations.
- Ensure resources handle loading, error, cancellation, and refetch states.
- Keep server/client code separated in SolidStart routes and server functions.

## Astro and islands

- Keep island hydration deliberate: hydrate only components that need client interactivity.
- Avoid shipping large framework runtimes for static content.
- Keep browser-only code inside client components or client directives.
- Ensure server-rendered content and hydrated islands agree on initial state.

## Web components and vanilla DOM

- Clean up event listeners, observers, timers, and object URLs in lifecycle callbacks.
- Reflect attributes/properties intentionally and avoid infinite update loops.
- Use event delegation where it simplifies dynamic DOM updates.
- Preserve semantic HTML and keyboard behavior for custom elements.
- Avoid direct `innerHTML` with untrusted content.

## CSS and styling systems

- Follow the repository's established styling system before introducing a new one.
- Avoid global CSS leakage unless the selector is intentionally global.
- Prefer scoped styles, design tokens, CSS custom properties, or utility classes according to project conventions.
- Check responsive states, dark mode, reduced motion, high contrast, and text overflow where relevant.
