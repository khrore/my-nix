<!-- markdownlint-disable MD013 -->

# Repository

## Problem

Policy code needs persisted objects without depending on storage details.

## Direct Shape

```ts
const row = await db.query("select * from invoices where id=?", [id]);
if (row.status === "draft") await db.query("update invoices set status=?", ["approved"]);
```

## Pattern Shape

```ts
interface InvoiceRepository {
  require(id: InvoiceId): Promise<Invoice>;
  save(invoice: Invoice): Promise<void>;
}
```

## Tests

- Repository contract tests cover each implementation.
- Not-found and duplicate behavior are explicit.
- Policy tests use an in-memory fake.

## Misuse Signals

- Repository mirrors every table.
- Query language leaks through the contract.
- The implementation introduces more concepts than the requirement needs.
