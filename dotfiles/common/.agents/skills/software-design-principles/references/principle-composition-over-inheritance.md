<!-- markdownlint-disable MD013 -->

# Composition Over Inheritance

## Problem

Behavior reuse is hidden in parent classes, lifecycle hooks, or template chains that make variants fragile.

## Forces

- Shared behavior should be explicit at assembly points.
- Inheritance couples variants to base-class state and ordering.
- Delegation keeps reusable pieces small and testable.

## When to Use

- A subclass exists only to reuse helper code.
- Every new variant adds another override.
- Base-class defaults or hooks make changes risky.
- Config, CI, or script templates inherit side effects.

## When Not to Use

- The subtype relationship is real and stable.
- The local framework expects inheritance and the override surface is narrow.
- Delegation would create more moving parts than the hierarchy.

## Implementation Shape

- Extract shared behavior into focused collaborators.
- Pass collaborators through constructors or function parameters.
- Keep variant-specific decisions local.
- Expose a clear contract at the assembly point.

## Pressure Example

```ts
abstract class Importer {
  protected parse(raw: string): Row[] { return parseCsv(raw); }
  protected validate(rows: Row[]) { /* shared mutable state */ }
  abstract source(): Promise<string>;

  async run() {
    const rows = this.parse(await this.source());
    this.validate(rows);
    return rows;
  }
}

class S3Importer extends Importer { source() { return s3.read("rows.csv"); } }
```

## Possible Refactoring

```ts
type Source = { read(): Promise<string> };
type Parser = { parse(raw: string): Row[] };
type Validator = { validate(rows: Row[]): void };

async function importRows(source: Source, parser: Parser, validator: Validator) {
  const rows = parser.parse(await source.read());
  validator.validate(rows);
  return rows;
}
```

## Tests

- Test `importRows` with fake source, parser, and validator.
- Test each source adapter separately.
- Verify adding a new source does not require changing parser or validator code.

## Misuse Signals

- Composition that creates many pass-through wrappers.
- Replacing a clear stable hierarchy with scattered callbacks.
- Collaborators that expose more state than the base class did.
