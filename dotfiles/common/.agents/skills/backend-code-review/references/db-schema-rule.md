<!-- markdownlint-disable MD013 MD031 -->

# Rule Catalog — DB Schema Design

## Scope

- Covers: schema boundaries in model/entity definitions, migrations, tenant-aware schema design, index redundancy,
  dialect portability, constraints, and cross-database compatibility across Python, Go, and Rust backends.
- Does NOT cover: transaction boundaries and query execution patterns (handled by `persistence-rule.md` and
  `sqlalchemy-rule.md`).

## Rules

### Keep model/entity computed fields local and side-effect free

- Category: [maintainability, performance]
- Severity: critical
- Description: Model/entity computed properties, getters, serializers, or trait methods must not open database sessions
  or query other tables. Hidden I/O inside local-looking accessors causes tight coupling and N+1 query explosions.
- Suggested fix:
  - Keep computed fields pure and based on already-loaded data.
  - Move cross-table data fetching to service/repository methods.
  - For list/batch reads, fetch related data explicitly with joins, preloads, or bulk queries before rendering derived
    values.
- Example:
  - Bad:
    ```python
    @property
    def app_name(self) -> str:
        app = db.session.execute(select(App).where(App.id == self.app_id)).scalar_one()
        return app.name
    ```
  - Good:
    ```python
    @property
    def display_title(self) -> str:
        return self.name or "Untitled"
    ```

### Prefer including tenant ownership in schema definitions

- Category: maintainability
- Severity: suggestion
- Description: In multi-tenant domains, tenant-owned entities should include a tenant/organization/account column. This
  improves data isolation, indexing, partitioning, and future sharding strategies.
- Suggested fix:
  - Add a `tenant_id`, `org_id`, or equivalent column for tenant-owned data.
  - Include tenant dimensions in relevant unique constraints and indexes.
  - Document explicit exceptions for global metadata tables.
- Example:
  ```sql
  CREATE TABLE datasets (
      id UUID PRIMARY KEY,
      tenant_id UUID NOT NULL,
      name VARCHAR(255) NOT NULL,
      CONSTRAINT datasets_tenant_name_unique UNIQUE (tenant_id, name)
  );
  ```

### Enforce invariants with constraints, not only application code

- Category: correctness
- Severity: suggestion
- Description: Important invariants such as uniqueness, required fields, foreign keys, and valid statuses should be
  represented in the schema when possible. Application-only checks can race under concurrent writes or be bypassed by
  alternate code paths.
- Suggested fix:
  - Add `NOT NULL`, `UNIQUE`, `CHECK`, and `FOREIGN KEY` constraints where supported and compatible.
  - Keep application validation for user-friendly errors, but rely on schema constraints for final enforcement.
  - For dialects with limited check enforcement, document the compatibility trade-off.

### Detect and avoid duplicate or redundant indexes

- Category: performance
- Severity: suggestion
- Description: Review index definitions for leftmost-prefix redundancy. For example, index `(tenant_id, app_id, created_at)` often covers lookups for `(tenant_id, app_id)`. Keeping both can increase write overhead and mislead the
  optimizer unless a measured query pattern needs the shorter index.
- Suggested fix:
  - Compare new indexes against existing composite indexes before adding one.
  - Keep wider indexes when they cover required access patterns, unless profiling proves a dedicated shorter index is
    beneficial.
  - Apply the same review in model/entity declarations and migration DDL.
- Example:
  - Bad:
    ```sql
    CREATE INDEX idx_msg_tenant_app ON messages (tenant_id, app_id);
    CREATE INDEX idx_msg_tenant_app_created ON messages (tenant_id, app_id, created_at);
    ```
  - Good:
    ```sql
    CREATE INDEX idx_msg_tenant_app_created ON messages (tenant_id, app_id, created_at);
    ```

### Keep migrations portable or guard dialect-specific behavior

- Category: maintainability
- Severity: critical
- Description: Migrations and schema definitions should account for the databases the service supports. Unconditional
  PostgreSQL-only, MySQL-only, or SQLite-only syntax can break deployments, tests, or local development.
- Suggested fix:
  - Prefer portable column types and defaults when possible.
  - Branch by dialect for incompatible SQL fragments.
  - Encapsulate dialect-specific types in shared adapters/wrappers in the language stack.
  - Document deliberate single-database decisions.
- Examples:
  - Python/SQLAlchemy: wrap dialect-specific model types in `models.types`.
  - Go: isolate dialect differences in migration files or driver-specific repository code.
  - Rust: keep `sqlx` queries/migrations aligned with the configured database feature set.

### Make destructive migrations reversible and operationally safe

- Category: reliability
- Severity: critical
- Description: Dropping columns, backfilling large tables, changing nullability, or rewriting data can lock tables or lose
  data if deployed in one step.
- Suggested fix:
  - Prefer expand/backfill/contract migrations for large or production tables.
  - Add nullable columns first, backfill in batches, then enforce `NOT NULL` or constraints.
  - Provide downgrade or rollback notes when full reversal is impossible.
  - Avoid long transactions for large backfills.
