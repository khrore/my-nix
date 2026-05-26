<!-- markdownlint-disable MD013 MD031 -->

# Rule Catalog — Persistence and Data-Access Safety

## Scope

- Covers: transaction boundaries, query construction, tenant/ownership scoping, raw SQL, concurrency safeguards,
  resource cleanup, and write-path idempotency across Python, Go, and Rust backends.
- Complements language-specific rules such as `sqlalchemy-rule.md`, `go-rule.md`, and `rust-rule.md`.

## Rules

### Bound every transaction explicitly

- Category: correctness
- Severity: critical
- Description: Write paths need a clear transaction boundary with explicit commit/rollback behavior. Long or implicit
  transactions increase contention and can silently lose writes when errors are mishandled.
- Suggested fix:
  - Keep transactions short and avoid network I/O or expensive computation inside them.
  - Ensure rollback runs on every error path.
  - Commit only after all writes in the unit are complete and validated.
- Examples:
  - Go:

    ```go
    tx, err := db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()

    if _, err := tx.ExecContext(ctx, query, args...); err != nil {
        return err
    }

    return tx.Commit()
    ```

  - Rust:
    ```rust
    let mut tx = pool.begin().await?;
    sqlx::query!("UPDATE jobs SET status = $1 WHERE id = $2", status, job_id)
        .execute(&mut *tx)
        .await?;
    tx.commit().await?;
    ```

### Enforce tenant and ownership predicates on shared resources

- Category: security
- Severity: critical
- Description: Reads and writes against tenant-owned or user-owned data must include tenant/owner predicates. Looking up
  by object ID alone can leak or corrupt data across tenants or users.
- Suggested fix:
  - Propagate tenant/user context through service and repository interfaces.
  - Include tenant/owner predicates in reads, writes, deletes, uniqueness checks, and affected-row validation.
  - Treat missing affected rows on scoped writes as not-found or conflict, not success.
- Example:
  ```sql
  UPDATE workflow_runs
  SET status = $1
  WHERE id = $2 AND tenant_id = $3
  ```

### Prefer parameterized queries and query builders over string concatenation

- Category: security
- Severity: critical
- Description: Query strings built with interpolation, concatenation, or formatting can introduce SQL injection and
  broken escaping. This also makes query review harder.
- Suggested fix:
  - Use placeholders and bound parameters.
  - Use ORM/query-builder APIs for composable filters when available.
  - If dynamic identifiers are unavoidable, validate against an allowlist before interpolation.
- Examples:
  - Bad:
    ```go
    query := "SELECT * FROM users WHERE email = '" + email + "'"
    ```
  - Good:
    ```go
    row := db.QueryRowContext(ctx, "SELECT * FROM users WHERE email = ?", email)
    ```

### Protect contested writes with a concurrency strategy

- Category: correctness
- Severity: critical
- Description: Multi-writer code can lose updates without optimistic locking, pessimistic locking, idempotency keys, or
  compare-and-swap semantics.
- Suggested fix:
  - Use optimistic locking for low-contention updates and retryable workflows.
  - Use `SELECT ... FOR UPDATE` or equivalent when strict serialization is required.
  - Use idempotency keys for external callbacks, retries, and job processing.
  - Check affected-row counts for conditional updates.
- Example:
  ```sql
  UPDATE accounts
  SET balance = $1, version = version + 1
  WHERE id = $2 AND tenant_id = $3 AND version = $4
  ```

### Close rows, bodies, cursors, and streams

- Category: reliability
- Severity: critical
- Description: Database cursors, HTTP bodies, files, and streams can leak connections or descriptors if not closed on
  every path.
- Suggested fix:
  - In Go, `defer rows.Close()` and `defer resp.Body.Close()` immediately after successful creation.
  - In Rust, prefer RAII-owned resources and avoid holding DB rows/transactions longer than needed.
  - In Python, use context managers for sessions, cursors, files, and clients.

### Add timeouts and cancellation to external work

- Category: reliability
- Severity: suggestion
- Description: Backend calls without cancellation can hang request handlers, goroutines, async tasks, or workers and
  exhaust pools under partial outages.
- Suggested fix:
  - Thread request context/deadlines through database, HTTP, RPC, and queue calls.
  - Use bounded retries with jittered backoff and clear idempotency semantics.
  - Avoid blocking calls inside async runtimes.
