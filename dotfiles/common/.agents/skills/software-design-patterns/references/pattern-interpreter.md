<!-- markdownlint-disable MD013 -->

# Interpreter

## Problem

A small language or expression grammar needs parsing and evaluation.

## Direct Shape

```ts
if (rule === "country=US AND total>100") { /* split strings ad hoc */ }
```

## Pattern Shape

```ts
type Expr = And | Equals | GreaterThan;
function evaluate(expr: Expr, order: Order): boolean {
  switch (expr.kind) { /* grammar cases */ }
}
```

## Tests

- Parser handles valid grammar.
- Invalid syntax fails clearly.
- Evaluator covers each expression node.

## Misuse Signals

- A few named options would work.
- Building a language to avoid product decisions.
- The implementation introduces more concepts than the requirement needs.
