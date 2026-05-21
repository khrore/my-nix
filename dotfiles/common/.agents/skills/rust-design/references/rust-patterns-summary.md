# Rust Design Patterns Summary

## Scope

This note summarizes the Design Patterns section of the Rust Design Patterns
book and distills it into selection guidance for day-to-day Rust work.

Primary sources:

- <https://rust-unofficial.github.io/patterns/patterns/index.html>
- <https://github.com/rust-unofficial/patterns/tree/main/src/patterns>

## Core message

- Design patterns are language-specific. Rust changes the tradeoffs because
  ownership, borrowing, enums, traits, and `Drop` remove or reshape many
  classic OO patterns.
- Apply YAGNI first. Prefer direct use of Rust features before introducing
  pattern scaffolding.
- Favor strong types, clear ownership, and narrow interfaces over clever
  abstraction layers.

## Pattern quick picks

- Use `newtype` when semantics matter more than representation: units, IDs,
  secrets, constrained values, or hiding implementation types behind a stable
  API.
- Use RAII guards when a resource must be acquired and then reliably released:
  locks, transactions, scoped capability access, temporary state changes.
- Use a builder when construction has many optional fields, staged validation,
  side effects, or future-compatible defaults.
- Use command when work must be deferred, queued, replayed, undone, or invoked
  from events. In Rust this can be traits, closures, or function pointers,
  depending on statefulness and dispatch needs.
- Use visitor when traversing heterogeneous recursive data without rebuilding
  it. Use fold when traversing and producing a new structure.
- Use a tiny DSL or macro-based interpreter only when the problem repeats often
  enough to justify a dedicated syntax.
- Split large structs into smaller pieces when independent borrowing is blocked
  by a monolithic type.
- Introduce a custom trait when generic bounds become noisy and obscure the
  domain concept.
- Prefer small crates and modules that do one thing well, but watch dependency
  sprawl and version conflicts.
- Keep `unsafe` in the smallest module that can uphold the invariant, then
  expose a safe outer interface.
- For FFI, prefer opaque Rust-owned handle types plus explicit transparent
  transfer types. Consolidate lifetime-sensitive state into a wrapper when that
  reduces use-after-free risk on the foreign side.

## Notes by section

### Behavioral

- Command:
  Encapsulate operations so they can run later, run in reverse, or be stored.
  Pick traits for rich stateful commands, function pointers for simple static
  operations, and closures for lightweight local customization.
- Interpreter:
  Reach for a DSL or `macro_rules!` only when the domain really benefits from a
  compact syntax. Do not create a mini-language for one-off convenience.
- Newtype:
  Treat tuple wrappers as a zero-cost way to add type safety, privacy, and API
  control. Expect some boilerplate in exchange for those guarantees.
- RAII guards:
  Bind capability access to lifetime and rely on `Drop` for cleanup. This is
  the standard shape for locks and other scoped resources.
- Strategy:
  Translate the intent into traits or closures instead of porting a classical
  class hierarchy literally. Rust often makes the pattern feel simpler than in
  OO languages.
- Visitor:
  Separate traversal from operation when multiple analyses share the same data
  model. Keep the traversal helpers reusable when possible.

### Creational

- Builder:
  Prefer when constructors would otherwise proliferate, especially because Rust
  lacks overloaded constructors and default parameters.
- Fold:
  Prefer for tree or graph-like transformations that produce a new structure.
  This is especially useful when immutable transforms are easier to reason
  about than in-place mutation.

### Structural

- Struct decomposition for independent borrowing:
  Use when borrow-checker friction is pointing at a single type that is doing
  too much.
- Prefer small crates:
  Treat crate boundaries as a design tool, not just packaging.
- Contain unsafety in small modules:
  Make invariants local and auditable.
- Use custom traits to avoid complex bounds:
  Replace unreadable generic signatures with named capability traits.

### FFI

- Object-based APIs:
  Export opaque handles that Rust owns, keep transactional transfer types
  transparent, and model library behavior as functions over those handles.
- Type consolidation into wrappers:
  Collapse related Rust objects into one wrapper on the foreign boundary when
  that is the safest way to preserve lifetime relationships.

## Practical heuristics

- Prefer enums over flag combinations when states are mutually exclusive.
- Prefer borrowed arguments at library boundaries unless ownership transfer is
  part of the contract.
- Prefer `From` or `TryFrom` and explicit constructors over ad hoc parsing or
  sentinel values.
- Prefer explicit invariants in type definitions over comments explaining how to
  use a loose structure correctly.
- Prefer composition over inheritance-style abstractions.
- Avoid cloning only to silence the borrow checker; redesign ownership first.
- Avoid exposing generic internals in public types unless callers truly benefit.
- Avoid pattern enthusiasm. A direct function or a small module is often the
  better Rust answer.

## Default stance

When in doubt, choose the smallest design that preserves:

1. clear ownership,
2. strong domain types,
3. explicit error boundaries,
4. local invariants,
5. room to extend without breaking callers.
