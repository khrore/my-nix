---
name: software-design-principles
description: Use when planning, reviewing, refactoring, or implementing language-agnostic software design. Applies SOLID, composition over inheritance, DRY, KISS, Law of Demeter, Design by Contract, encapsulation, command-query separation, least astonishment, self-documenting code, uniform access, single choice, and persistence closure as pragmatic heuristics.
---

# Software Design Principles

Use this skill to shape or review language-agnostic software design across code, scripts, configuration, schemas, CLIs, automation, and tests.

These principles are heuristics, not ceremony. Prefer the smallest change that reduces coupling, drift, surprise, invalid states, or maintenance cost. Do not add abstraction unless it removes real complexity, protects a real boundary, or matches an established local convention.

## How to Apply

- Start from the existing codebase shape, naming, and ownership boundaries.
- Load only the specific principle reference needed for the design pressure in front of you.
- Use references for problem recognition, examples, tests, and misuse signals.
- When principles conflict, favor simple, explicit code with stable boundaries and clear contracts.
- Recommend the smallest structural change that resolves the design pressure.

## Principle References

- **SOLID**: read `references/principle-solid.md`.
- **Composition Over Inheritance**: read `references/principle-composition-over-inheritance.md`.
- **DRY**: read `references/principle-dry.md`.
- **KISS**: read `references/principle-kiss.md`.
- **Law of Demeter**: read `references/principle-law-of-demeter.md`.
- **Design by Contract**: read `references/principle-design-by-contract.md`.
- **Encapsulation**: read `references/principle-encapsulation.md`.
- **Command-Query Separation**: read `references/principle-command-query-separation.md`.
- **Principle of Least Astonishment**: read `references/principle-least-astonishment.md`.
- **Linguistic Modular Units**: read `references/principle-linguistic-modular-units.md`.
- **Self-Documentation**: read `references/principle-self-documentation.md`.
- **Uniform Access**: read `references/principle-uniform-access.md`.
- **Single Choice**: read `references/principle-single-choice.md`.
- **Persistence Closure**: read `references/principle-persistence-closure.md`.

## Output Guidance

When using these principles in a review or plan:

- Lead with concrete risks and file or API references when available.
- Explain the design pressure, not just the principle name.
- State the smallest change that addresses the pressure.
- Mention tradeoffs only when they affect the decision.
