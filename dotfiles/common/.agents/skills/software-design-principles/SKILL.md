---
name: software-design-principles
description: >-
  Apply language-agnostic design principles when planning or reviewing a
  refactor, API, module boundary, state model, or other concrete design decision.
  Use when coupling, duplicated knowledge, unclear ownership, surprising
  behavior, invalid states, or unstable contracts materially affect the task;
  do not invoke for routine code changes without such a design pressure.
---

<!-- markdownlint-disable MD013 -->

# Software Design Principles

Use design principles as diagnostic lenses, not compliance rules. Start from the observed pressure and recommend the
smallest change that reduces meaningful coupling, drift, surprise, invalid state, or maintenance cost.

Reference examples illustrate one possible refactoring in TypeScript-like notation. Preserve a simpler local design when
it already addresses the pressure, and adapt any example to the language and repository conventions in front of you.

## Choose the Relevant Lens

Load only the reference that helps explain the current decision. Use more than one only when each reveals a distinct
tradeoff.

- Mixed responsibilities or unstable dependency direction: [SOLID](references/principle-solid.md)
- Fragile inheritance or behavior reuse: [Composition Over Inheritance](references/principle-composition-over-inheritance.md)
- Duplicated change-prone knowledge: [DRY](references/principle-dry.md) or
  [Single Choice](references/principle-single-choice.md)
- Excess concepts or accidental complexity: [KISS](references/principle-kiss.md)
- Excess knowledge of collaborators: [Law of Demeter](references/principle-law-of-demeter.md)
- Unclear inputs, outputs, invariants, or failure behavior:
  [Design by Contract](references/principle-design-by-contract.md)
- Leaking internals or unstable mutation rules: [Encapsulation](references/principle-encapsulation.md)
- Reads with hidden writes or commands with surprising query behavior:
  [Command-Query Separation](references/principle-command-query-separation.md)
- Surprising names, defaults, or side effects: [Least Astonishment](references/principle-least-astonishment.md)
- Vague or unnatural module boundaries: [Linguistic Modular Units](references/principle-linguistic-modular-units.md)
- Structure that cannot explain itself: [Self-Documentation](references/principle-self-documentation.md)
- Callers coupled to storage versus computation: [Uniform Access](references/principle-uniform-access.md)
- Persisted state invalid without omitted context: [Persistence Closure](references/principle-persistence-closure.md)

## Apply Pragmatically

- Describe the concrete pressure before naming a principle.
- Respect the repository's existing ownership, naming, and extension boundaries.
- Distinguish duplicated knowledge from code that only looks similar.
- Prefer explicit parameters, focused helpers, and cohesive modules before introducing frameworks or broad interfaces.
- State the tradeoff when improving one principle makes another quality worse.
- Preserve public behavior unless the task explicitly includes a contract change or migration.
- Recommend tests around the behavior or boundary that was previously difficult to reason about.
- Do not report a principle violation unless it creates a meaningful present risk or obstructs the requested change.

For reviews and plans, lead with the risk and smallest useful change. Principle names may explain the reasoning, but they
are not findings by themselves.
