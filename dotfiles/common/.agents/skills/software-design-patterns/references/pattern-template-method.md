<!-- markdownlint-disable MD013 -->

# Template Method

## Problem

A workflow has fixed steps but some steps vary in subclasses.

## Direct Shape

```ts
class CsvImporter { async run() { await read(); parseCsv(); validate(); save(); } }
class JsonImporter { async run() { await read(); parseJson(); validate(); save(); } }
```

## Pattern Shape

```ts
abstract class Importer {
  async run() { const raw = await this.read(); const rows = this.parse(raw); validate(rows); await save(rows); }
  protected abstract read(): Promise<string>;
  protected abstract parse(raw: string): Row[];
}
```

## Tests

- Workflow order is fixed and tested once.
- Each hook is tested by variant.
- Subclass cannot skip required validation.

## Misuse Signals

- Inheritance is only for reuse.
- Composition would express variable steps more clearly.
- The implementation introduces more concepts than the requirement needs.
