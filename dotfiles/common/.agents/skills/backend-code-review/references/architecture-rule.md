<!-- markdownlint-disable MD013 MD031 -->

# Rule Catalog — Architecture

## Scope

- Covers: handler/controller/service/use-case/domain/library/model layering, dependency direction, responsibility placement,
  and observability-friendly flow across Python, Go, and Rust backend code.

## Rules

### Keep business logic out of transport handlers

- Category: maintainability
- Severity: critical
- Description: HTTP/RPC handlers should parse input, perform boundary validation, authorize, call services/use cases, and
  serialize responses. Business decisions in handlers are hard to reuse, test, and protect consistently.
- Suggested fix:
  - Move domain/business rules into services, use cases, or pure domain functions.
  - Keep handlers thin and orchestration-focused.
  - Pass explicit actor/tenant/request context into the service layer instead of reading global web state in domain code.
- Examples:
  - Bad:
    ```go
    func PublishApp(w http.ResponseWriter, r *http.Request) {
        force := r.URL.Query().Get("force") == "true"
        if force && currentUser(r).Role != "admin" {
            http.Error(w, "only admin can force publish", http.StatusForbidden)
            return
        }
        // Direct persistence and business transition in handler.
        db.ExecContext(r.Context(), "UPDATE apps SET status = 'published' WHERE id = ?", appID(r))
    }
    ```
  - Good:
    ```go
    func PublishApp(w http.ResponseWriter, r *http.Request) {
        input := decodePublishRequest(r)
        if err := appService.Publish(r.Context(), input.AppID, input.Force, currentUser(r).ID); err != nil {
            writeError(w, err)
            return
        }
        writeJSON(w, http.StatusOK, map[string]string{"result": "ok"})
    }
    ```

### Preserve layer dependency direction

- Category: best practices
- Severity: critical
- Description: Transport/adapters may depend on services/use cases; services may depend on domain contracts; domain code
  should not depend on web frameworks, SQL clients, queues, or concrete infrastructure. Reversing this direction creates
  cycles and leaks framework concerns into business rules.
- Suggested fix:
  - Define contracts at the domain/use-case boundary.
  - Put framework, database, queue, and HTTP client details in adapters/infrastructure modules.
  - Inject dependencies through constructors, traits/interfaces/protocols, or explicit function parameters.
- Examples:
  - Bad:

    ```rust
    // domain/policy.rs
    use axum::extract::Request;

    pub fn can_publish(req: &Request) -> bool {
        req.extensions().get::<User>().is_some_and(|u| u.is_admin)
    }
    ```

  - Good:

    ```rust
    // domain/policy.rs
    pub fn can_publish(role: Role) -> bool {
        role == Role::Admin
    }

    // adapter maps web request context to domain input.
    let allowed = can_publish(current_user.role);
    ```

### Keep shared libraries business-agnostic

- Category: maintainability
- Severity: critical
- Description: Generic library/helper modules should remain reusable building blocks. They must not encode product
  workflow, tenant policy, pricing rules, or business decisions.
- Suggested fix:
  - Move business logic into services/use cases/domain modules.
  - Keep shared libraries focused on generic utilities such as time, validation primitives, serialization, hashing,
    retry helpers, or collection transformations.
  - Avoid importing service/controller/domain-specific modules into low-level shared libraries.
- Example:
  - Bad:

    ```python
    # libs/conversation_filter.py
    from services.billing import has_paid_plan

    def should_archive(conversation, tenant_id: str) -> bool:
        return conversation.idle_days > (90 if has_paid_plan(tenant_id) else 30)
    ```

  - Good:

    ```python
    # libs/datetime_utils.py
    def older_than_days(idle_days: int, threshold_days: int) -> bool:
        return idle_days > threshold_days

    # services/conversation_service.py
    threshold_days = 90 if billing.has_paid_plan(tenant_id) else 30
    should_archive = older_than_days(conversation.idle_days, threshold_days)
    ```

### Keep observability at boundaries without leaking secrets

- Category: reliability
- Severity: suggestion
- Description: Backend flows should emit useful logs/traces/metrics at request, job, and integration boundaries, but
  must not log secrets, credentials, tokens, raw PII, or full untrusted payloads.
- Suggested fix:
  - Log stable identifiers, tenant/user IDs where safe, operation names, durations, and sanitized error classes.
  - Add trace spans around external dependencies and expensive operations.
  - Redact or hash sensitive values before logging.
