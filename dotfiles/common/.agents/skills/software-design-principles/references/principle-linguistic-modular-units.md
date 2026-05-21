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

## Problem Example

```ts
// utils.ts
export function doStuff(input: any) { /* parses invoice, charges card, sends mail */ }
```

## Refactored Example

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

## Review Checklist

- Can you name the design pressure without naming the principle?
- Does the proposed change reduce real coupling, drift, surprise, or invalid state?
- Is the smallest useful boundary visible in names, types, or module layout?
- Are validation and failure behavior explicit at the edge where callers enter?
- Does the refactor preserve current behavior while making the next change safer?
- Would an ordinary maintainer know where to make the next related edit?

## Refactoring Moves

- Start with a narrow local change before introducing a broad abstraction.
- Move knowledge to the owner that already maintains the relevant invariant.
- Prefer explicit parameters, small helpers, and named value objects before frameworks.
- Add tests around the behavior that was hard to reason about before the refactor.
- Keep compatibility at public boundaries unless the task explicitly includes migration.

## Example Reading Guide

- The problem example shows the smell to recognize in real code.
- The refactored example shows one possible shape, not the only valid implementation.
- Translate classes, interfaces, and modules into the host language's natural units.
- Preserve local conventions when they already solve the same problem clearly.
