<!-- markdownlint-disable MD013 MD031 -->

# Rule Catalog — Go Backend Review

## Scope

- Covers: idiomatic Go backend code in handlers, services, repositories, workers, CLIs, integration clients, and tests.
- Complements cross-language architecture, repository, schema, and persistence rules.

## Rules

### Propagate `context.Context` through request-scoped work

- Category: reliability
- Severity: critical
- Description: Database, HTTP, RPC, queue, and long-running operations should accept and pass `context.Context` so
  callers can cancel work and enforce deadlines.
- Suggested fix:
  - Accept `ctx context.Context` as the first parameter on request-scoped service/repository methods.
  - Use `QueryContext`, `ExecContext`, `NewRequestWithContext`, and client APIs that honor cancellation.
  - Do not store contexts in structs except for explicitly long-lived lifecycle objects.
- Example:
  ```go
  func (r *UserRepository) FindByID(ctx context.Context, tenantID, userID string) (*User, error) {
      row := r.db.QueryRowContext(ctx, query, tenantID, userID)
      // scan and return
  }
  ```

### Handle errors explicitly and preserve context

- Category: correctness
- Severity: critical
- Description: Ignored errors, broad fallback behavior, or string-only errors hide failed I/O and make debugging
  production failures difficult.
- Suggested fix:
  - Check every returned `error` unless there is a documented reason not to.
  - Wrap errors with operation context using `%w`.
  - Use `errors.Is`/`errors.As` for sentinel and typed errors.
- Example:
  ```go
  if err := svc.Publish(ctx, id); err != nil {
      return fmt.Errorf("publish app %s: %w", id, err)
  }
  ```

### Close resources on every path

- Category: reliability
- Severity: critical
- Description: Leaked `Rows`, HTTP response bodies, files, tickers, timers, and goroutines can exhaust resources under
  load.
- Suggested fix:
  - Close `rows`, `resp.Body`, files, tickers, and timers immediately after successful creation.
  - Drain or discard response bodies when connection reuse matters.
  - Ensure goroutines have cancellation and exit paths.
- Example:
  ```go
  rows, err := db.QueryContext(ctx, query, args...)
  if err != nil {
      return err
  }
  defer rows.Close()
  ```

### Avoid goroutine and channel leaks

- Category: reliability
- Severity: critical
- Description: Goroutines started from handlers or workers must terminate when the request/job is canceled. Sends to
  unbuffered channels without a receiver can deadlock.
- Suggested fix:
  - Select on `ctx.Done()` in loops and blocking sends/receives.
  - Use `errgroup.WithContext` for related concurrent work.
  - Avoid fire-and-forget goroutines unless they are owned by an application lifecycle component.

### Keep handler responsibilities thin

- Category: maintainability
- Severity: suggestion
- Description: HTTP/RPC handlers should decode, validate, authorize, call services, and encode responses. Business
  rules, persistence, and orchestration belong in services/use cases and repositories.
- Suggested fix:
  - Move business decisions into services or domain functions.
  - Keep repository calls behind service methods unless the handler is a deliberately tiny internal endpoint.

### Use race-safe state management

- Category: correctness
- Severity: critical
- Description: Shared maps, slices, caches, metrics state, and lazy initialization can race across requests or workers.
- Suggested fix:
  - Protect shared mutable state with `sync.Mutex`, `sync.RWMutex`, `sync.Map`, atomics, or immutable replacement.
  - Run or recommend `go test -race` for code touching concurrency.
  - Prefer dependency initialization at startup over lazy global mutation.

### Test behavior with table-driven cases and realistic failures

- Category: testing
- Severity: suggestion
- Description: Backend logic should cover success, validation, authorization, persistence failure, context cancellation,
  and boundary cases.
- Suggested fix:
  - Use table-driven tests for branching business logic.
  - Use `httptest`, fake repositories, or transactional test DBs for integration points.
  - Assert response codes, error types, side effects, and tenant scoping.
