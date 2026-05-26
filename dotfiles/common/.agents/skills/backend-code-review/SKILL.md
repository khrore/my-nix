---
name: backend-code-review
description: >-
  Review backend code for quality, security, maintainability, language idioms,
  and data-access correctness across Python, Go, and Rust. Use when the user
  requests a review, analysis, or improvement of backend files such as `.py`,
  `.go`, or `.rs` in service, API, worker, CLI, persistence, or domain layers.
---

<!-- markdownlint-disable MD013 MD031 -->

# Backend Code Review

## When to use this skill

Use this skill whenever the user asks to **review, analyze, or improve** backend code in Python, Go, or Rust.
Backend scope includes API handlers/controllers, services/use cases, domain/core modules, workers/jobs, CLIs, database
models/migrations/repositories, infrastructure adapters, and integration clients.

Supported review modes:

- **Pending-change review**: inspect staged and working-tree backend files slated for commit.
- **Code snippet review**: review pasted functions, classes, structs, traits, handlers, queries, migrations, or modules.
- **File-focused review**: review the specific backend files or directories the user names.

Keep the scope tight: review only what the user provided or explicitly referenced.

## Review process

1. **Identify the review mode**: pending-change, snippet, or file-focused.
1. **Identify languages and layers** in scope:
   - Python: `.py`, Alembic migrations, SQLAlchemy models/repositories/services.
   - Go: `.go`, `cmd/`, `internal/`, `pkg/`, HTTP/RPC handlers, repositories, workers.
   - Rust: `.rs`, `src/`, `crates/`, handlers, services, repositories, async tasks.
1. **Apply the matching checklist rules** below. If multiple languages or layers are present, apply every relevant rule.
1. **Prioritize findings by severity**:
   - Critical: security issue, data loss/corruption risk, cross-tenant leak, broken transaction/concurrency behavior,
     panic/crash on normal input, or clear production correctness bug.
   - Suggestion: maintainability, performance, idiomatic usage, testability, or resilience improvement.
   - Nit: low-risk style, naming, or local clarity issue.
1. **Compose the final output** using the Required Output Format exactly.

Notes:

- Always include actionable fixes or suggestions. Include code snippets when they make the fix clearer.
- Use best-effort `FilePath: <path> line <line>` references when available. For snippets, use the most specific
  symbol or excerpt location available.
- Do not invent unavailable context. If a finding depends on unknown framework behavior, state the assumption.

## Checklist

### Cross-language backend rules

- **Architecture and layering**: if the scope involves handler/controller/service/use-case/domain/library/model layering,
  dependency direction, or responsibility placement, follow
  [references/architecture-rule.md](references/architecture-rule.md).
- **Persistence and repository boundaries**: if the scope contains direct database/cache/blob-store access, ad-hoc SQL,
  ORM/query-builder calls, or repeated CRUD/query logic, follow
  [references/repositories-rule.md](references/repositories-rule.md).
- **Database schema and migrations**: if the scope includes models/entities, migrations, schema DDL, indexes, constraints,
  tenant boundaries, or dialect portability, follow [references/db-schema-rule.md](references/db-schema-rule.md).
- **General data-access safety**: if the scope includes transactions, query construction, raw SQL, tenant scoping,
  concurrency, or write paths in any language, follow [references/persistence-rule.md](references/persistence-rule.md).

### Language-specific rules

- **Python / SQLAlchemy**: if the scope uses SQLAlchemy sessions, ORM/Core expressions, Alembic migrations, or Python DB
  repositories, follow [references/sqlalchemy-rule.md](references/sqlalchemy-rule.md) in addition to the generic rules.
- **Go**: if the scope includes `.go` files, follow [references/go-rule.md](references/go-rule.md).
- **Rust**: if the scope includes `.rs` files, follow [references/rust-rule.md](references/rust-rule.md).

## General Review Rules

### 1. Security Review

Check for:

- SQL/NoSQL injection and unsafe query composition.
- SSRF, command injection, path traversal, and unsafe file handling.
- Insecure deserialization or unsafe parsing of untrusted data.
- Hardcoded secrets, credentials, tokens, private keys, or test keys used in production paths.
- Improper authentication, authorization, tenant scoping, or ownership checks.
- Insecure direct object references.
- Sensitive data leaks in logs, traces, errors, metrics, or panic messages.

### 2. Reliability and Correctness Review

Check for:

- Missing or incorrect error handling.
- Ambiguous transaction boundaries, missing commits/rollbacks, or long-running transactions.
- Lost updates and races on multi-writer paths.
- Non-idempotent retry behavior in workers, jobs, or external integrations.
- Resource leaks: unclosed files, HTTP bodies, DB rows/cursors, timers, goroutines, tasks, or channels.
- Panic/unwrap/expect paths reachable from normal user input or external data.

### 3. Performance Review

Check for:

- N+1 queries, missing preloads/joins/batch reads, or unbounded list operations.
- Missing or redundant database indexes for important access paths.
- Blocking operations in async runtimes or request hot paths.
- Avoidable allocations, unnecessary copies/clones, reflection-heavy hot paths, or repeated serialization.
- Missing timeouts, cancellation, backpressure, pagination, streaming, or caching on expensive operations.

### 4. Code Quality Review

Check for:

- Code forward compatibility and framework-version assumptions.
- Code duplication and repeated business rules.
- Functions/modules doing too much.
- Deep nesting or complex conditionals that obscure failure paths.
- Magic numbers/strings without named constants or configuration.
- Poor naming, unclear boundaries, or hidden side effects.
- Incomplete type coverage, overly broad dynamic values, or weak domain modeling.

### 5. Testing Review

Check for:

- Missing tests for new behavior, failure paths, authorization, and tenant isolation.
- Tests that assert implementation details instead of observable behavior.
- Flaky tests caused by time, network, database order, concurrency, or global state.
- Missing edge cases for empty input, malformed input, cancellation/timeouts, and partial failures.

## Required Output Format

When this skill is invoked, the response must exactly follow one of the two templates:

### Template A (any findings)

```markdown
# Code Review Summary

Found <X> critical issues need to be fixed:

## Critical (Must Fix)

### 1. <brief description of the issue>

FilePath: <path> line <line>
<relevant code snippet or pointer>

#### Explanation

<detailed explanation and references of the issue>

#### Suggested Fix

1. <brief description of suggested fix>
2. <code example> (optional, omit if not applicable)

---

... (repeat for each critical issue) ...

Found <Y> suggestions for improvement:

## Suggestions (Should Consider)

### 1. <brief description of the suggestion>

FilePath: <path> line <line>
<relevant code snippet or pointer>

#### Explanation

<detailed explanation and references of the suggestion>

#### Suggested Fix

1. <brief description of suggested fix>
2. <code example> (optional, omit if not applicable)

---

... (repeat for each suggestion) ...

Found <Z> optional nits:

## Nits (Optional)

### 1. <brief description of the nit>

FilePath: <path> line <line>
<relevant code snippet or pointer>

#### Explanation

<explanation and references of the optional nit>

#### Suggested Fix

- <minor suggestions>

---

... (repeat for each nits) ...

## What's Good

- <Positive feedback on good patterns>
```

- If there are no critical issues, suggestions, optional nits, or good points, omit that section.
- If the issue count is more than 10, summarize as "Found 10+ critical issues/suggestions/optional nits" and only
  output the first 10 items.
- Don't compress the blank lines between sections; keep them as-is for readability.
- If any issue requires code changes, append a brief follow-up question asking whether the user wants to apply the fixes
  after the structured output. For example: "Would you like me to use the Suggested fix(es) to address these issues?"

### Template B (no issues)

```markdown
## Code Review Summary

No issues found.
```
