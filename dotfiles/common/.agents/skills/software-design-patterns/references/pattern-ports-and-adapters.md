<!-- markdownlint-disable MD013 -->

# Ports and Adapters

## Problem

Core logic depends on infrastructure, delivery mechanisms, providers, or persistence details.

## Direct Shape

```ts
async function approve(id: string) {
  const row = await prisma.invoice.findUnique({ where: { id } });
  await sendgrid.send(renderApproval(row));
}
```

## Pattern Shape

```ts
interface InvoiceStore { require(id: string): Promise<Invoice>; }
interface Notifier { approved(invoice: Invoice): Promise<void>; }

async function approve(id: string, store: InvoiceStore, notifier: Notifier) {
  const invoice = await store.require(id);
  invoice.approve();
  await notifier.approved(invoice);
}
```

## Tests

- Core policy tests use fake ports.
- Adapters translate external errors.
- Assembly wires real infrastructure at the edge.

## Misuse Signals

- Ports mirror SDK APIs.
- Every internal call is forced through a port even though no meaningful boundary exists.
- The implementation introduces more concepts than the requirement needs.
