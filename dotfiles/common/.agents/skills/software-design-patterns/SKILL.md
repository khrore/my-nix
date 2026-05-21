---
name: software-design-patterns
description: Use when implementing or refactoring code with a concrete recurring design problem such as interchangeable behavior, object construction, external integration, state transitions, event notification, command execution, workflow composition, persistence boundaries, or dependency boundaries. Helps choose and apply named software design patterns without unnecessary abstraction.
---

# Software Design Patterns

Use this skill when implementation needs a recurring design shape, not whenever code is being written. A named pattern is useful only when it removes real complexity, clarifies a stable variation point, protects a boundary, or matches an established local convention.

Prefer plain functions, modules, structs, records, helpers, and direct calls when they solve the problem clearly. Do not introduce pattern vocabulary, interfaces, factories, inheritance, or indirection just because a pattern could fit.

For broad architecture layering, dependency-rule enforcement, entities, use cases, and full ports-and-adapters architecture, use `clean-architecture` instead.

## Selection Rules

- Start from the pressure in the code: variation, construction, integration, state, events, commands, wrapping, persistence, dependencies, traversal, or object families.
- Load only the specific pattern reference needed for the design pressure in front of you.
- Choose the smallest pattern form that makes the pressure explicit and testable.
- Keep public contracts narrow and named after the domain or capability, not the pattern.
- Stop before speculative generality: support the variations that exist now or are required by the current change.

## Pattern References

- **Abstract Factory**: read `references/pattern-abstract-factory.md`.
- **Adapter**: read `references/pattern-adapter.md`.
- **Bridge**: read `references/pattern-bridge.md`.
- **Builder**: read `references/pattern-builder.md`.
- **Chain of Responsibility**: read `references/pattern-chain-of-responsibility.md`.
- **Command**: read `references/pattern-command.md`.
- **Composite**: read `references/pattern-composite.md`.
- **Decorator**: read `references/pattern-decorator.md`.
- **Dependency Injection**: read `references/pattern-dependency-injection.md`.
- **Facade**: read `references/pattern-facade.md`.
- **Factory Method**: read `references/pattern-factory-method.md`.
- **Flyweight**: read `references/pattern-flyweight.md`.
- **Interpreter**: read `references/pattern-interpreter.md`.
- **Iterator**: read `references/pattern-iterator.md`.
- **Mediator**: read `references/pattern-mediator.md`.
- **Memento**: read `references/pattern-memento.md`.
- **Observer**: read `references/pattern-observer.md`.
- **Ports and Adapters**: read `references/pattern-ports-and-adapters.md`.
- **Prototype**: read `references/pattern-prototype.md`.
- **Proxy**: read `references/pattern-proxy.md`.
- **Pub-Sub**: read `references/pattern-pub-sub.md`.
- **Repository**: read `references/pattern-repository.md`.
- **Simple Factory**: read `references/pattern-simple-factory.md`.
- **Singleton**: read `references/pattern-singleton.md`.
- **Specification**: read `references/pattern-specification.md`.
- **State**: read `references/pattern-state.md`.
- **Strategy**: read `references/pattern-strategy.md`.
- **Template Method**: read `references/pattern-template-method.md`.
- **Unit of Work**: read `references/pattern-unit-of-work.md`.
- **Visitor**: read `references/pattern-visitor.md`.

## Output Guidance

When recommending a pattern:

- Name the concrete pressure it solves.
- Explain why a simpler construct is insufficient.
- State the smallest contract or interface needed.
- Identify where construction, selection, or assembly belongs.
- List tests that prove the pattern preserves behavior and handles expected variations.
