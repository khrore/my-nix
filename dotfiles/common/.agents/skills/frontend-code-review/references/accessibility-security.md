<!-- markdownlint-disable MD013 MD024 MD031 -->

# Rule Catalog — Frontend Accessibility and Security

## Scope

Covers accessibility, browser security, unsafe HTML, URL/file handling, storage, secrets, and user-controlled navigation across frontend frameworks.

## Rules

### Preserve semantic and keyboard accessibility

IsUrgent: True
Category: Accessibility

#### Description

Interactive UI must be reachable and understandable with keyboard and assistive technology. Clickable `div`s, missing labels, hidden focus, and non-semantic controls block users and often violate product requirements.

#### Suggested Fix

- Prefer native controls such as `button`, `a`, `input`, `select`, and `label`.
- Add accessible names for icon-only controls.
- Preserve focus indicators and logical tab order.
- Implement keyboard behavior for custom widgets according to ARIA patterns.

### Handle focus and announcements in dynamic UI

IsUrgent: True
Category: Accessibility

#### Description

Modals, drawers, route changes, validation errors, async updates, and toasts need deliberate focus management and announcements so assistive technology users are not stranded.

#### Suggested Fix

- Move focus into modal/dialog content and restore focus on close.
- Associate validation messages with fields.
- Use live regions sparingly for important async status changes.
- Keep route-change headings and document titles accurate.

### Avoid unsafe HTML and template injection

IsUrgent: True
Category: Security

#### Description

Rendering user-controlled HTML, Markdown, SVG, or template strings can introduce XSS when sanitization and trust boundaries are unclear.

#### Suggested Fix

- Avoid raw HTML APIs by default: `dangerouslySetInnerHTML`, `v-html`, Svelte `{@html}`, Angular `bypassSecurityTrust*`, `innerHTML`, and similar APIs.
- If raw HTML is required, sanitize with an approved sanitizer and document the trusted source.
- Do not interpolate untrusted values into scripts, styles, URLs, or templates.

### Validate URLs and navigation targets

IsUrgent: True
Category: Security

#### Description

User-controlled URLs can cause open redirects, `javascript:` execution, tabnabbing, or navigation to untrusted origins.

#### Suggested Fix

- Allowlist internal routes or trusted origins for redirects.
- Reject dangerous protocols such as `javascript:` and unexpected `data:` URLs.
- Add `rel="noopener noreferrer"` for external links opened in a new tab.
- Prefer router link components for internal navigation.

### Keep secrets out of frontend bundles

IsUrgent: True
Category: Security

#### Description

Anything shipped to the browser is public. API keys, private tokens, signing secrets, service credentials, and privileged feature flags must not be embedded in client bundles or source maps.

#### Suggested Fix

- Use only explicitly public environment variables in frontend code.
- Move privileged calls behind backend endpoints.
- Check that build-time environment injection does not expose server-only secrets.

### Treat file and clipboard input as untrusted

IsUrgent: True
Category: Security

#### Description

Uploaded files, drag-and-drop payloads, pasted HTML, and clipboard data can contain malicious content, huge payloads, or unexpected MIME types.

#### Suggested Fix

- Validate file size, type, extension, and content where possible.
- Avoid rendering pasted/uploaded HTML directly.
- Revoke object URLs when previews are no longer needed.
- Handle parsing failures with user-friendly errors.

### Avoid leaking sensitive data in telemetry

IsUrgent: True
Category: Security

#### Description

Logs, analytics, replay tools, error trackers, and performance traces can accidentally capture tokens, PII, form values, URLs, or API responses.

#### Suggested Fix

- Redact sensitive fields before logging or reporting errors.
- Avoid sending full request/response bodies to client telemetry.
- Scrub query parameters and route segments that may contain secrets or personal data.
