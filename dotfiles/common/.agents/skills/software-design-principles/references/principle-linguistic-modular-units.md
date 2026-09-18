<!-- markdownlint-disable MD013 -->

# Linguistic Modular Units

## Problem

Core behavior is hidden behind ad hoc structure instead of natural language or framework boundaries.

## Forces

- Code is easier to navigate when units match concepts.
- Languages already provide files, modules, functions, classes, schemas, and commands.
- Custom structures should earn their complexity.

## When to Use

- A directory named `misc` owns central behavior.
- A config template language hides business rules.
- One file mixes unrelated command, schema, and runtime concepts.
- A helper name describes steps, not capability.

## When Not to Use

- The local framework convention already defines a clear unit.
- A generated structure is required by tooling.
- Splitting would separate a cohesive concept.

## Implementation Shape

- Name modules after owned concepts or capabilities.
- Move behavior into the smallest natural unit that owns it.
- Use language-native boundaries before custom organization schemes.

## Pressure Example

```ts
// utils.ts
export function doStuff(input: any) { /* parses invoice, charges card, sends mail */ }
```

## Possible Refactoring

```ts
// invoice-parser.ts
export function parseInvoice(input: RawInvoice): InvoiceDraft { /* ... */ }

// payment-service.ts
export async function chargeInvoice(invoice: InvoiceDraft): Promise<Receipt> { /* ... */ }
```

## Tests

- Tests are organized by capability, not utility file.
- Renaming or moving a unit makes ownership clearer.
- No behavior is reachable only through a vague catch-all module.

## Misuse Signals

- Creating many tiny files for one cohesive operation.
- Renaming without improving ownership.
- Fighting required framework file layout.
