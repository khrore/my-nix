<!-- markdownlint-disable MD013 -->

# Bridge

## Problem

An abstraction and its implementation vary independently, causing inheritance combinations to multiply.

## Direct Shape

```ts
class CsvEmailReport extends EmailReport {}
class PdfEmailReport extends EmailReport {}
class CsvSlackReport extends SlackReport {}
class PdfSlackReport extends SlackReport {}
```

## Pattern Shape

```ts
interface ReportFormat { render(data: Data): Bytes; }
interface Delivery { send(bytes: Bytes): Promise<void>; }

class Report {
  constructor(private format: ReportFormat, private delivery: Delivery) {}
  async publish(data: Data) { await this.delivery.send(this.format.render(data)); }
}
```

## Tests

- Test each format independently.
- Test each delivery independently.
- Test report composition for representative pairs.

## Misuse Signals

- Only one axis varies.
- Composition names are vague and hide the domain concept.
- The implementation introduces more concepts than the requirement needs.
