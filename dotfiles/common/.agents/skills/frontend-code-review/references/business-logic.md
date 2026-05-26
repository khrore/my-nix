<!-- markdownlint-disable MD013 MD024 MD031 -->

# Rule Catalog — Frontend Business Logic

## Scope

Covers placement of product rules, UI/domain boundaries, authorization assumptions, validation, route behavior, persistence, and cross-framework frontend correctness.

## Rules

### Keep product rules out of generic UI components

IsUrgent: False
Category: Business Logic

#### Description

Reusable UI primitives should not encode product workflow, plan limits, tenant policy, feature flags, or API-specific behavior. Mixing product rules into generic components makes them hard to reuse and easy to break across flows.

#### Suggested Fix

- Put product rules in route/page components, feature modules, services, stores, or domain helpers.
- Keep design-system components focused on rendering, accessibility, and simple interaction contracts.
- Pass already-computed state such as `disabled`, `reason`, or `variant` into generic components.

### Do not rely on frontend authorization alone

IsUrgent: True
Category: Business Logic

#### Description

Frontend permission checks improve UX but do not secure data or actions. Hidden buttons, disabled form fields, or client-side route guards can be bypassed.

#### Suggested Fix

- Keep client-side guards for UX, but verify that backend APIs enforce authorization and ownership.
- Treat server responses such as `401`, `403`, and tenant mismatch as first-class UI states.
- Avoid exposing unauthorized data in preloaded route state, embedded JSON, or client caches.

### Validate and normalize boundary data

IsUrgent: True
Category: Business Logic

#### Description

Route params, query strings, forms, browser storage, feature flags, postMessage events, and API responses are external data. Trusting them directly can cause crashes, invalid actions, or security issues.

#### Suggested Fix

- Validate route params, query params, form payloads, and API responses before use.
- Normalize data once at the boundary instead of scattering coercion across components.
- Represent validation, loading, empty, error, and success states explicitly.

### Keep routing and navigation behavior predictable

IsUrgent: False
Category: Business Logic

#### Description

Frontend flows should handle deep links, back/forward navigation, reloads, redirects, unsaved changes, and missing records consistently.

#### Suggested Fix

- Use the framework/router's navigation APIs instead of ad-hoc `window.location` changes when possible.
- Preserve important state in URLs when users need shareable or reload-safe views.
- Add unsaved-change guards for destructive navigation where product behavior requires them.

### Keep client persistence deliberate

IsUrgent: True
Category: Business Logic

#### Description

LocalStorage, sessionStorage, IndexedDB, cookies, and in-memory caches can expose sensitive data, create stale UI, and conflict across tabs or users.

#### Suggested Fix

- Do not store access tokens, secrets, or sensitive PII in unsafe browser storage unless the architecture explicitly accepts the risk.
- Version and expire persisted client state.
- Clear user-scoped caches on logout, tenant switch, and account switch.
- Handle multi-tab synchronization when state can change elsewhere.

### Make optimistic UI and retries safe

IsUrgent: True
Category: Business Logic

#### Description

Optimistic updates, offline queues, retries, and duplicate submissions can show incorrect state or perform actions multiple times if rollback and idempotency are missing.

#### Suggested Fix

- Disable or debounce duplicate submissions when actions are not idempotent.
- Roll back optimistic state on failure or reconcile with server state.
- Use idempotency keys or server-supported conflict handling for retried mutations.
- Show partial-failure and retry states clearly.
