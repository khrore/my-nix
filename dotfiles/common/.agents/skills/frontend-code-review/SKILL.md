---
name: frontend-code-review
description: >-
  Review frontend JavaScript and TypeScript code across React, Vue, Svelte,
  Angular, Solid, Astro, web components, and vanilla browser apps. Use when the
  user requests a review, analysis, or improvement of frontend files such as
  `.js`, `.jsx`, `.ts`, `.tsx`, `.vue`, `.svelte`, `.astro`, `.html`, `.css`,
  or styling modules.
---

<!-- markdownlint-disable MD013 MD024 MD031 -->

# Frontend Code Review

## When to use this skill

Use this skill whenever the user asks to **review, analyze, or improve** frontend code in JavaScript, TypeScript, or framework-specific single-file components.
Frontend scope includes browser UI components, pages/routes, client state, forms, data fetching, routing, CSS/styling, accessibility, build-time rendering, and frontend integration code.

Supported review modes:

1. **Pending-change review**: inspect staged and working-tree frontend files slated for commit.
2. **Code snippet review**: review pasted components, composables/hooks, stores, routes, forms, styles, tests, or modules.
3. **File-focused review**: review the specific frontend files or directories the user names.

Keep the scope tight: review only what the user provided or explicitly referenced.

## Review process

1. **Identify the review mode**: pending-change, snippet, or file-focused.
2. **Identify frameworks and file types** in scope:
   - React/Preact/Next/Remix: `.jsx`, `.tsx`, hooks, components, routes, server/client boundaries.
   - Vue/Nuxt: `.vue`, composables, refs/reactivity, props/emits, route components.
   - Svelte/SvelteKit: `.svelte`, stores, load functions, actions, reactive statements.
   - Angular: `.ts`, templates, standalone components, services, signals/RxJS, modules.
   - Solid/SolidStart: signals, resources, effects, route components.
   - Astro/web components/vanilla: islands, custom elements, DOM APIs, CSS, HTML.
3. **Apply the matching checklist rules** below. If multiple frameworks are present, apply every relevant rule.
4. **Prioritize findings**:
   - Urgent: security issue, accessibility blocker, hydration/runtime crash, broken state/data flow, data loss, cross-user leak, or clear production correctness bug.
   - Suggestion: maintainability, performance, framework idiom, testability, resilience, or UX improvement.
   - Nit: low-risk style, naming, or local clarity issue.
5. **Compose the final output** using the Required Output Format exactly.

Notes:

- Always include actionable fixes or suggestions. Include code snippets when they make the fix clearer.
- Use best-effort `FilePath: <path> line <line>` references when available. For snippets, use the most specific symbol or excerpt location available.
- Do not invent unavailable project conventions. If a finding depends on an unknown framework, build tool, or design-system convention, state the assumption.
- Prefer project-defined patterns over generic advice when the repository clearly documents them.

## Checklist

Treat these reference files as the canonical checklist for frontend reviews:

- [references/code-quality.md](references/code-quality.md): framework boundaries, component API design, state/effect correctness, TypeScript quality, styling maintainability, and tests.
- [references/performance.md](references/performance.md): rendering costs, reactivity pitfalls, bundle size, network behavior, hydration, media, and async work.
- [references/business-logic.md](references/business-logic.md): UI/domain boundary, authorization assumptions, validation, routing, persistence, and feature-specific behavior.
- [references/accessibility-security.md](references/accessibility-security.md): a11y, XSS, unsafe HTML, URL/file handling, browser storage, secrets, CSP-sensitive code, and user-controlled navigation.
- [references/frameworks.md](references/frameworks.md): framework-specific review cues for React, Vue, Svelte, Angular, Solid, Astro, web components, and vanilla DOM code.

Flag each rule violation with urgency metadata so future reviewers can prioritize fixes.

## Required output

When invoked, the response must exactly follow one of the two templates:

### Template A (any findings)

```markdown
# Code review

Found <N> urgent issues need to be fixed:

## 1 <brief description of bug>

FilePath: <path> line <line>
<relevant code snippet or pointer>

### Suggested fix

<brief description of suggested fix>

---

... (repeat for each urgent issue) ...

Found <M> suggestions for improvement:

## 1 <brief description of suggestion>

FilePath: <path> line <line>
<relevant code snippet or pointer>

### Suggested fix

<brief description of suggested fix>

---

... (repeat for each suggestion) ...
```

If there are no urgent issues, omit that section. If there are no suggestions, omit that section.

If the issue number is more than 10, summarize as "10+ urgent issues" or "10+ suggestions" and just output the first 10 issues.

Don't compress the blank lines between sections; keep them as-is for readability.

If you use Template A and at least one issue requires code changes, append a brief follow-up question after the structured output asking whether the user wants you to apply the suggested fixes. For example: "Would you like me to use the Suggested fix section to address these issues?"

### Template B (no issues)

```markdown
## Code review

No issues found.
```
