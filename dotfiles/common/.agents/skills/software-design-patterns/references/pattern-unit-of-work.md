<!-- markdownlint-disable MD013 -->

# Unit of Work

## Problem

Multiple persistence operations must commit or roll back together.

## Direct Shape

```ts
await invoices.save(invoice);
await ledger.save(entry);
// second write can fail after first commits
```

## Pattern Shape

```ts
await unitOfWork.run(async tx => {
  await tx.invoices.save(invoice);
  await tx.ledger.save(entry);
});
```

## Tests

- Both writes commit on success.
- Failure rolls back all writes.
- Commit cannot be forgotten by callers.

## Misuse Signals

- Global hidden transaction.
- Only one simple write exists.
- The implementation introduces more concepts than the requirement needs.
