<!-- markdownlint-disable MD013 MD031 -->

# Rule Catalog — Rust Backend Review

## Scope

- Covers: idiomatic Rust backend code in handlers, services, repositories, workers, CLIs, async tasks, integration clients,
  and tests.
- Complements cross-language architecture, repository, schema, and persistence rules.

## Rules

### Avoid `unwrap`, `expect`, and panics on normal input paths

- Category: correctness
- Severity: critical
- Description: Backend code reachable from user input, external APIs, queues, files, or databases must not panic on
  malformed or unexpected data. Panics can crash workers, abort requests, or drop in-flight work.
- Suggested fix:
  - Return `Result` and use `?` to propagate failures.
  - Convert external errors into domain or API errors at boundaries.
  - Reserve `expect` for invariant violations with a message proving why the invariant holds.
- Example:
  ```rust
  let user_id = request.user_id.parse::<Uuid>()
      .map_err(|err| ApiError::bad_request("invalid user_id", err))?;
  ```

### Keep async code non-blocking

- Category: performance
- Severity: critical
- Description: Blocking filesystem, network, CPU-heavy, or synchronous database work inside an async runtime can stall
  unrelated requests and tasks.
- Suggested fix:
  - Use async clients and async database pools in async handlers.
  - Move CPU-heavy or blocking work to `spawn_blocking` or a dedicated worker pool.
  - Do not hold mutex guards, DB transactions, or borrowed request state across unnecessary `.await` points.

### Model errors with useful context

- Category: maintainability
- Severity: suggestion
- Description: Stringly typed errors or erased context make it hard for callers to distinguish validation, not-found,
  conflict, dependency, and internal failures.
- Suggested fix:
  - Use typed errors with `thiserror` or explicit enums in domain/service layers.
  - Add context with `anyhow::Context` in binaries/adapters where typed recovery is not needed.
  - Map internal errors to safe API responses without leaking secrets or raw SQL.

### Respect ownership instead of cloning by default

- Category: performance
- Severity: suggestion
- Description: Unnecessary `clone()` calls can hide ownership problems and add avoidable allocation costs on hot paths.
- Suggested fix:
  - Borrow with `&T`, `&str`, or slices where ownership is not required.
  - Use `Arc` intentionally for shared ownership across tasks.
  - Keep clones when they simplify boundaries and the data is small or not hot-path critical.

### Preserve `Send` and cancellation safety in spawned tasks

- Category: reliability
- Severity: critical
- Description: Spawned async tasks must own required data safely, finish on shutdown/cancellation, and not hold
  non-`Send` values across `.await` when running on multi-threaded executors.
- Suggested fix:
  - Pass cancellation tokens or shutdown channels into long-running tasks.
  - Use `tokio::select!` around loops waiting on work.
  - Avoid capturing request-scoped borrows in spawned tasks.

### Keep database transactions short and explicit

- Category: correctness
- Severity: critical
- Description: Holding a transaction across external calls or many `.await` points increases lock duration and deadlock
  risk. Dropping a transaction without commit should be deliberate and visible.
- Suggested fix:
  - Start transactions as late as possible and commit as soon as the write unit is complete.
  - Avoid HTTP/RPC calls and expensive computation inside transactions.
  - Check affected-row counts for conditional updates.

### Limit unsafe code and document invariants

- Category: security
- Severity: critical
- Description: `unsafe` blocks must be rare in backend application code and must document the invariants that make them
  sound. Unreviewed unsafe code can introduce memory safety vulnerabilities.
- Suggested fix:
  - Prefer safe abstractions and well-reviewed crates.
  - Isolate unsafe code in a small module with tests.
  - Add `SAFETY:` comments explaining caller and data invariants.

### Test observable behavior and failure paths

- Category: testing
- Severity: suggestion
- Description: Backend tests should cover success, validation, authorization, repository failures, cancellation/timeouts,
  and concurrency-sensitive paths.
- Suggested fix:
  - Use focused unit tests for domain logic.
  - Use integration tests with temporary databases or testcontainers where persistence behavior matters.
  - Use `tokio::test` for async behavior and time controls for timeout/retry logic.
