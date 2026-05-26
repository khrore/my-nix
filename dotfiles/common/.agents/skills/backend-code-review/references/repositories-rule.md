<!-- markdownlint-disable MD013 MD031 -->

# Rule Catalog — Repositories and Persistence Boundaries

## Scope

- Covers: when to reuse existing repository/data-access abstractions, when to introduce new ones, and how to preserve
  dependency direction between service/domain code and infrastructure implementations across Python, Go, and Rust.
- Does NOT cover: transaction lifecycle and query-safety specifics (handled by `persistence-rule.md` and
  `sqlalchemy-rule.md`) or table schema/migration design (handled by `db-schema-rule.md`).

## Rules

### Reuse existing repository abstractions

- Category: maintainability
- Severity: suggestion
- Description: If an entity/table already has a repository, DAO, store, gateway, trait, or interface abstraction, new
  reads/writes for that entity should go through it. Bypassing existing abstractions duplicates query policy and often
  skips tenant scoping, eager loading, locking, or cache invalidation.
- Suggested fix:
  - First search existing repository/store modules for the entity.
  - Add missing methods to the existing abstraction instead of issuing ad-hoc SQL/ORM calls from services or handlers.
  - Preserve dependency direction: service/domain code depends on contracts; infrastructure provides implementations.
- Examples:
  - Go:

    ```go
    type AppRepository interface {
        GetByID(ctx context.Context, tenantID, appID string) (*App, error)
        Save(ctx context.Context, app *App) error
    }

    type AppService struct {
        apps AppRepository
    }
    ```

  - Rust:
    ```rust
    #[async_trait::async_trait]
    pub trait AppRepository: Send + Sync {
        async fn get_by_id(&self, tenant_id: TenantId, app_id: AppId) -> Result<App, RepoError>;
        async fn save(&self, app: &App) -> Result<(), RepoError>;
    }
    ```

### Introduce repositories only when complexity justifies them

- Category: maintainability
- Severity: suggestion
- Description: Not every table or query needs a new abstraction. Introducing one too early adds indirection; introducing
  one too late scatters complex query logic and policy.
- Suggested fix:
  - Introduce a repository/store abstraction when query logic is repeated, complex, tenant-sensitive, high-volume, or
    likely to vary by storage backend.
  - Keep trivial one-off infrastructure reads close to their adapter when they do not leak into domain logic.
  - Name methods by business intent (`ListActiveForTenant`) rather than implementation details (`SelectWhereStatus`).

### Keep raw persistence APIs out of domain logic

- Category: maintainability
- Severity: critical
- Description: Domain entities and pure business rules should not import SQL clients, ORM sessions, Redis clients,
  filesystem clients, web frameworks, or queue clients. That couples business behavior to infrastructure and makes tests
  slow and brittle.
- Suggested fix:
  - Move persistence into repositories/adapters.
  - Pass already-loaded domain data into pure domain functions.
  - Use interfaces/traits/protocols for use cases that need persistence.
- Example:
  - Bad:
    ```rust
    pub async fn can_archive(pool: &PgPool, conversation_id: Uuid) -> Result<bool, sqlx::Error> {
        let row = sqlx::query!("SELECT idle_days FROM conversations WHERE id = $1", conversation_id)
            .fetch_one(pool)
            .await?;
        Ok(row.idle_days > 30)
    }
    ```
  - Good:
    ```rust
    pub fn can_archive(conversation: &Conversation, threshold_days: i32) -> bool {
        conversation.idle_days > threshold_days
    }
    ```

### Keep repository contracts tenant-aware where data is tenant-owned

- Category: security
- Severity: critical
- Description: Repository APIs that accept only an object ID make it easy for callers to forget tenant or owner scoping.
- Suggested fix:
  - Include `tenant_id`, `account_id`, `org_id`, or owner context in repository method signatures for scoped data.
  - Return not-found for records outside the caller's scope.
  - Make unscoped/admin-only access explicit in the method name and documentation.
