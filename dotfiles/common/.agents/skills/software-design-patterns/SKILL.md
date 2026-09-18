---
name: software-design-patterns
description: >-
  Choose or review a named software design pattern when implementation or
  refactoring has a concrete recurring pressure such as variation, construction,
  integration, state, events, commands, composition, persistence, or dependency
  boundaries. Do not use merely because a familiar pattern could fit.
---

<!-- markdownlint-disable MD013 -->

# Software Design Patterns

Use patterns to make an existing design pressure easier to understand, test, or change. Prefer a plain function,
module, data structure, or direct call when it solves the current problem clearly.

The reference examples are small TypeScript-shaped sketches, not prescriptions. Adapt them to the host language and
local conventions, and keep the direct shape when the pattern shape does not produce a clear present benefit.

## Decide From the Pressure

Load only the reference for the most plausible candidate. Compare a second pattern only when the tradeoff is genuinely
unclear.

- Interchangeable policy or behavior: [Strategy](references/pattern-strategy.md),
  [State](references/pattern-state.md), [Specification](references/pattern-specification.md), or
  [Template Method](references/pattern-template-method.md)
- Construction and related object families: [Builder](references/pattern-builder.md),
  [Simple Factory](references/pattern-simple-factory.md), [Factory Method](references/pattern-factory-method.md),
  [Abstract Factory](references/pattern-abstract-factory.md), or [Prototype](references/pattern-prototype.md)
- External systems and dependency boundaries: [Adapter](references/pattern-adapter.md),
  [Facade](references/pattern-facade.md), [Proxy](references/pattern-proxy.md),
  [Dependency Injection](references/pattern-dependency-injection.md), or
  [Ports and Adapters](references/pattern-ports-and-adapters.md)
- Persistence boundaries: [Repository](references/pattern-repository.md) or
  [Unit of Work](references/pattern-unit-of-work.md)
- Object composition or added behavior: [Composite](references/pattern-composite.md),
  [Decorator](references/pattern-decorator.md), [Bridge](references/pattern-bridge.md), or
  [Flyweight](references/pattern-flyweight.md)
- Ordered processing or represented operations: [Chain of Responsibility](references/pattern-chain-of-responsibility.md),
  [Command](references/pattern-command.md), or [Interpreter](references/pattern-interpreter.md)
- Coordination, traversal, snapshots, or operations over stable structures:
  [Mediator](references/pattern-mediator.md), [Iterator](references/pattern-iterator.md),
  [Memento](references/pattern-memento.md), or [Visitor](references/pattern-visitor.md)
- In-process or decoupled events: [Observer](references/pattern-observer.md) or
  [Pub-Sub](references/pattern-pub-sub.md)
- A truly process-wide identity or resource: [Singleton](references/pattern-singleton.md), treated as a last-resort
  lifecycle choice rather than a convenience for global access

## Apply With Restraint

- Name the concrete pressure without relying on the pattern name.
- Check whether existing project conventions already solve it.
- Explain why a simpler construct is insufficient for the present requirement.
- Use the smallest domain-named contract that makes the pressure explicit.
- Keep selection and assembly in one discoverable place.
- Preserve current behavior and add tests around the variation or boundary the pattern is meant to protect.
- Reject the pattern when it adds concepts without reducing coupling, duplication, invalid states, or change cost.

When recommending a pattern, describe the pressure, minimal shape, tradeoff, and evidence that it will help. Do not turn a
local conditional or single implementation into a framework for hypothetical future variants.
