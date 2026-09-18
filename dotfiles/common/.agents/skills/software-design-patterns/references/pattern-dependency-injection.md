<!-- markdownlint-disable MD013 -->

# Dependency Injection

## Problem

High-level policy constructs or locates low-level collaborators directly.

## Direct Shape

```ts
class InvoiceService {
  private mailer = new SmtpMailer(process.env.SMTP_URL);
  async send(invoice: Invoice) { await this.mailer.send(invoice); }
}
```

## Pattern Shape

```ts
class InvoiceService {
  constructor(private mailer: Mailer) {}
  async send(invoice: Invoice) { await this.mailer.send(invoice); }
}
```

## Tests

- Policy works with a fake collaborator.
- Production assembly wires the concrete dependency.
- Missing dependency fails early.

## Misuse Signals

- DI container hides a tiny graph.
- Service locator is passed everywhere.
- The implementation introduces more concepts than the requirement needs.
