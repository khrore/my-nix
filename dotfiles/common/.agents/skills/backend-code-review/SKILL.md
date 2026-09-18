---
name: backend-code-review
description: >-
  Review Python, Go, or Rust backend code for concrete correctness, security,
  reliability, performance, and maintainability risks. Use when the user
  explicitly requests a review or analysis of backend code, a diff, or pending
  changes. Do not use for implementation or bug-fix requests unless a review is
  also requested.
---

<!-- markdownlint-disable MD013 -->

# Backend Code Review

Review the requested backend scope for actionable risks. Treat this guidance as decision support, not as an exhaustive
checklist. Apply only the rules relevant to the observed code, its execution path, and the user's question.

## Establish Scope

- Identify whether the user supplied a diff, files, directories, or a snippet. Do not silently expand beyond that scope.
- Read nearby code, tests, and project guidance when they are needed to understand intent or prove a finding.
- Identify the language, framework, data stores, trust boundaries, and concurrency model actually present.
- Prefer repository conventions when they already address the same risk safely.

## Review Method

- Understand the intended behavior before judging its structure.
- Trace relevant inputs through validation, authorization, business rules, persistence, external calls, and outputs.
- Look for concrete failure paths, not merely code that differs from a preferred style.
- Treat missing context as an assumption or question rather than inventing a defect.
- Report a maintainability concern only when it creates meaningful coupling, drift, ambiguity, or change risk.
- Recommend the smallest fix that addresses the demonstrated problem. Do not require a new abstraction by default.

## Calibrate Priority

Assign priority from the observed consequence, likelihood, and affected scope; reference wording is only a cue.

- **Critical**: a credible path to a security breach, cross-tenant access, data loss or corruption, broken concurrency or
  transaction behavior, crash on normal input, or another production correctness failure.
- **Important**: a likely reliability, performance, portability, testability, or maintenance problem with a meaningful
  operational or development cost.
- **Optional**: a local improvement with limited impact. Include these sparingly and only when useful to the requested
  depth of review.

Do not promote a hypothetical edge case without showing how the reviewed code can reach it. Conversely, do not soften a
clear security or data-integrity issue because the fix is inconvenient.

## Load Relevant References

Read only the references that match the code under review:

- Layering, dependency direction, or responsibility placement:
  [architecture-rule.md](references/architecture-rule.md)
- Repository abstractions and persistence boundaries:
  [repositories-rule.md](references/repositories-rule.md)
- Models, migrations, constraints, indexes, or schema portability:
  [db-schema-rule.md](references/db-schema-rule.md)
- Transactions, query construction, tenant scoping, contested writes, or resource cleanup:
  [persistence-rule.md](references/persistence-rule.md)
- SQLAlchemy sessions, expressions, migrations, or Python repositories:
  [sqlalchemy-rule.md](references/sqlalchemy-rule.md)
- Go code: [go-rule.md](references/go-rule.md)
- Rust code: [rust-rule.md](references/rust-rule.md)

Multiple references may apply to one data path, but do not load unrelated catalogs merely for completeness.

## Present the Review

- Follow a format requested by the user. Otherwise lead with findings ordered by priority.
- For each finding, give the location, observed behavior, concrete impact, supporting reasoning, and a practical fix.
- Keep code examples short and include them only when they clarify the correction.
- Distinguish confirmed defects from context-dependent risks or open questions.
- Omit empty severity sections, ceremonial summaries, and praise added only to balance criticism.
- If there are no actionable findings, say so briefly and mention any material validation limitation.
