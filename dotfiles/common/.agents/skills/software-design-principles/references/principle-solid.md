<!-- markdownlint-disable MD013 -->

# SOLID

## Problem

A unit changes for unrelated reasons, new variants require central edits, or callers depend on broad concrete details.

## Forces

- Cohesion keeps code testable.
- Contracts should be stable where variants exist.
- Interfaces should expose only what callers need.
- Policy should not import volatile infrastructure details.

## When to Use

- A module mixes policy, orchestration, validation, and I/O.
- A switch grows for every provider or mode.
- Adapters or implementations cannot be substituted cleanly.
- A high-level workflow constructs SDK clients or reads host paths directly.

## When Not to Use

- There is one simple concrete implementation and no test or volatility boundary.
- Splitting the code would scatter a cohesive concept.
- A registry would hide direct, readable control flow.

## Implementation Shape

- Identify the actor or reason-to-change for each unit.
- Define the smallest contract at the policy boundary.
- Move concrete tooling to outer assembly code.
- Add variants by adding implementations, not editing unrelated policy.

## Pressure Example

```ts
type ReportJob = { kind: string; path: string };

async function runReport(job: ReportJob) {
  if (job.kind === "csv") {
    const fs = new LocalFileSystem("/var/reports");
    return fs.write(job.path, renderCsv(loadRows()));
  }
  if (job.kind === "pdf") {
    const pdf = new PdfSdk(process.env.PDF_TOKEN);
    return pdf.renderAndUpload(job.path, loadRows());
  }
}
```

## Possible Refactoring

```ts
interface ReportRenderer {
  render(rows: Row[]): Promise<ReportBytes>;
}

interface ReportStore {
  save(path: string, bytes: ReportBytes): Promise<void>;
}

async function runReport(job: ReportJob, renderer: ReportRenderer, store: ReportStore) {
  const bytes = await renderer.render(loadRows());
  await store.save(job.path, bytes);
}
```

## Tests

- Contract test each renderer with the same rows and expected report metadata.
- Verify `runReport` does not construct filesystem or SDK dependencies.
- Add one selection test where outer assembly chooses the renderer.

## Misuse Signals

- Interfaces with one implementation and no boundary.
- A plugin system for two stable cases.
- Tiny cohesive functions split only to satisfy labels.
