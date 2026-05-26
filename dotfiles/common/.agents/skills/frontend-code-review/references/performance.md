<!-- markdownlint-disable MD013 MD024 MD031 -->

# Rule Catalog — Frontend Performance

## Scope

Covers rendering, reactivity, hydration, network usage, bundle size, media, and client-side resource management across JavaScript/TypeScript frontend frameworks.

## Rules

### Avoid unnecessary render or reactive churn

IsUrgent: False
Category: Performance

#### Description

Unstable references, expensive template expressions, broad store subscriptions, and large reactive dependencies can make components re-render or recompute more often than needed.

#### Suggested Fix

- Stabilize objects/functions only when identity matters: memoized children, effect dependencies, context/provider values, third-party APIs, or measured hot paths.
- Narrow store subscriptions/selectors to the data a component actually needs.
- Move expensive derived data into memoized/computed/derived primitives when repeated during render.
- Do not request memoization for every inline value by default.

### Prevent unbounded DOM work

IsUrgent: True
Category: Performance

#### Description

Rendering large lists, tables, canvases, maps, timelines, or graphs without pagination, virtualization, or incremental rendering can block the main thread and make the UI unusable.

#### Suggested Fix

- Add pagination, virtual scrolling, windowing, clustering, or progressive rendering for large collections.
- Avoid layout thrashing by batching DOM reads and writes.
- Use stable keys/identity for repeated items so frameworks can reconcile efficiently.

### Keep data fetching scoped and cancellable

IsUrgent: True
Category: Performance

#### Description

Duplicate fetches, un-cancelled requests, request waterfalls, and stale responses can waste bandwidth and show incorrect UI after navigation or input changes.

#### Suggested Fix

- Use the framework/router data-loading model when available.
- Cancel or ignore stale requests with `AbortController`, cleanup hooks, RxJS operators, query libraries, or framework-specific invalidation.
- Batch or parallelize independent requests when safe.
- Cache idempotent reads where the product behavior allows it.

### Protect hydration and server-rendered output

IsUrgent: True
Category: Performance

#### Description

SSR/SSG/hydrated apps can fail or re-render excessively when server markup differs from client markup. Random values, dates, locale-sensitive formatting, browser-only data, and user-specific state are common causes.

#### Suggested Fix

- Avoid non-deterministic values during server render unless serialized into the page.
- Defer client-only rendering until mount or use framework-specific client-only boundaries.
- Keep route-level data loading aligned between server and client.

### Watch bundle size and code splitting

IsUrgent: False
Category: Performance

#### Description

Large dependencies, eager imports, and all-in-one route bundles slow startup, especially on mobile or low-bandwidth networks.

#### Suggested Fix

- Lazy-load heavy route-only components, editors, charts, maps, syntax highlighters, and media tooling.
- Prefer tree-shakeable imports and avoid importing whole utility libraries for a small function.
- Check that server-only modules are not bundled into client code.

### Optimize images, fonts, and media

IsUrgent: False
Category: Performance

#### Description

Unoptimized images, blocking fonts, autoplaying media, and layout-shifting assets harm perceived performance and Core Web Vitals.

#### Suggested Fix

- Provide dimensions or aspect ratios for images and media.
- Use responsive image formats and lazy loading where appropriate.
- Preload only critical fonts/assets and use sensible font-display behavior.

### Move heavy CPU work off the hot path

IsUrgent: False
Category: Performance

#### Description

Parsing large payloads, formatting big datasets, encryption, compression, syntax highlighting, or complex filtering can block input and animations on the main thread.

#### Suggested Fix

- Debounce or throttle user-driven expensive work.
- Use web workers, idle callbacks, chunking, or server-side preprocessing when work is large.
- Keep animation and pointer-move handlers lightweight.
