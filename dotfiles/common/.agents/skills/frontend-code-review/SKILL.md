---
name: frontend-code-review
description: >-
  Review JavaScript, TypeScript, HTML, CSS, and frontend framework code for
  concrete correctness, accessibility, security, performance, and
  maintainability risks. Use when the user explicitly requests a review or
  analysis of frontend code, a diff, or pending changes. Do not use for
  implementation or bug-fix requests unless a review is also requested.
---

<!-- markdownlint-disable MD013 -->

# Frontend Code Review

Review the requested frontend scope for actionable risks. Treat the references as lenses for reasoning rather than a
list of mandatory findings. Apply a rule only when the code and product context make it relevant.

## Establish Scope

- Identify whether the user supplied a diff, files, directories, or a snippet. Keep the review within that scope.
- Read nearby components, tests, types, styles, and project guidance when they establish intent or conventions.
- Identify the framework, rendering model, browser/server boundary, state model, and styling system actually in use.
- Consider user-visible states such as loading, empty, error, permission, cancellation, and retry only when the feature
  can enter them.

## Review Method

- Understand the intended interaction and data flow before judging component structure.
- Follow external data through validation, state, rendering, navigation, persistence, and network mutations.
- Check accessibility and security at the boundary where user-controlled behavior enters the UI.
- Prefer concrete runtime, UX, or maintenance impact over generic framework advice.
- Treat missing context as an assumption or question instead of asserting a defect.
- Recommend the smallest correction consistent with the repository's existing patterns and design system.

## Calibrate Priority

Assign priority from demonstrated impact, reachability, and affected users; labels in references are only cues.

- **Critical**: a credible security issue, cross-user data exposure, data loss, inaccessible core workflow, runtime or
  hydration failure, or broken state/data flow affecting normal use.
- **Important**: a likely accessibility, resilience, performance, framework-correctness, or maintenance problem with
  meaningful user or development cost.
- **Optional**: a limited local improvement. Include it only when it helps the requested depth of review.

Do not call an issue critical solely because it matches a catalog entry. Explain the reachable consequence in the
reviewed code.

## Load Relevant References

Read only what matches the current files and behavior:

- Component boundaries, reactivity, TypeScript, styling, and tests:
  [code-quality.md](references/code-quality.md)
- Rendering, hydration, bundles, network work, and media:
  [performance.md](references/performance.md)
- Product rules, validation, routing, client persistence, and optimistic updates:
  [business-logic.md](references/business-logic.md)
- Accessibility, unsafe content, navigation, browser storage, files, and telemetry:
  [accessibility-security.md](references/accessibility-security.md)
- Framework-specific cues for the framework actually present:
  [frameworks.md](references/frameworks.md)

Do not load every reference merely because the project contains frontend code.

## Present the Review

- Follow a format requested by the user. Otherwise lead with findings ordered by priority.
- For each finding, give the location, observed behavior, user or system impact, evidence, and a practical fix.
- Use a code example only when it makes the correction materially clearer.
- Distinguish confirmed defects from context-dependent risks or questions.
- Omit empty sections, low-value nits, ceremonial summaries, and forced positive feedback.
- If there are no actionable findings, say so briefly and mention any material validation limitation.
