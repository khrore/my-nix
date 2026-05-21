---
name: rust-design
description: Design, review, refactor, and explain Rust code idiomatically. Use when Codex needs to work on Rust crates, modules, APIs, ownership and borrowing, lifetimes, traits and generics, async or concurrency, error handling, state modeling, FFI boundaries, unsafe containment, or performance-sensitive Rust code, especially when choosing abstractions or design patterns.
---

# Rust Design

## Overview

Use this skill to choose idiomatic Rust abstractions before or while writing code.
Prefer explicit ownership, narrow public APIs, strong types, and small audited
unsafe boundaries.

## Workflow

1. Classify the task.
- Distinguish library API design, internal refactor, bug fix, async or
  concurrency work, FFI, proc-macro work, or performance tuning.
- Determine whether the boundary is public and semver-sensitive or internal and
  free to simplify.

2. Model the data first.
- Prefer `struct`, `enum`, and `newtype` wrappers over strings, booleans, or
  loosely coupled tuples.
- Make invalid states unrepresentable.
- Use `Option`, `Result`, and enums to encode state transitions explicitly.
- Reach for a builder when construction has many optional knobs or staged
  validation.

3. Choose ownership deliberately.
- Prefer borrowed inputs such as `&str`, `&[T]`, `&Path`, `&OsStr`, or
  `impl AsRef<Path>` when the callee does not need ownership.
- Return owned data only when the caller needs independence.
- Treat cloning as a cost to justify, not a default escape hatch.
- Prefer composing smaller types over interior mutability or global shared
  state.

4. Design APIs around capabilities.
- Prefer traits and generics for compile-time polymorphism.
- Use trait objects only when runtime heterogeneity, plugin boundaries, or
  compile-time reduction matter more than static dispatch.
- Keep trait surfaces small and purpose-built.
- Introduce a custom trait when bounds become noisy or hide the domain concept.
- Prefer free functions or inherent impls over clever trait-based APIs unless
  reuse clearly improves the design.

5. Apply Rust-specific patterns.
- Use `newtype` for units, IDs, secrets, policy constraints, and API opacity.
- Use RAII guards to tie access to resource lifetime.
- Use the command pattern with traits, function pointers, or closures for
  deferred or undoable operations.
- Use builders for complex construction.
- Use visitor or fold for ASTs and other heterogeneous recursive data.
- Decompose large structs when independent borrowing is fighting the design.
- Prefer small crates or modules with a single responsibility.
- Keep `unsafe` in tiny modules with explicit invariants and a safe outer API.
- Read [rust-patterns-summary.md](references/rust-patterns-summary.md) when the
  task involves picking a pattern or translating an OO pattern into Rust.

6. Handle errors and concurrency intentionally.
- Use `Result<T, E>` for recoverable failures. Reserve panic for bugs or
  violated internal invariants.
- Prefer domain error enums in libraries and ergonomic error aggregation only
  at binary or application boundaries.
- Choose synchronous code by default. Adopt async when concurrency over I/O is
  required.
- Avoid holding locks across `.await`.
- Reach for task ownership or message passing before `Arc<Mutex<_>>`.

7. Validate the design before writing a large patch.
- Check whether public types expose implementation details unnecessarily.
- Check whether lifetimes are simplifying the API or leaking internal structure.
- Check whether `unsafe`, `Send`, `Sync`, pinning, or self-references introduce
  obligations that should be isolated.
- Check whether benchmarks or profiling are needed before adding complexity.

## Review Checklist

- Is the ownership model obvious from signatures?
- Are units, identifiers, and constrained values represented as strong types?
- Is the public API smaller than the internal implementation?
- Does error handling preserve context without erasing domain meaning?
- Does concurrency avoid accidental shared mutability?
- Is every `unsafe` block justified by a local invariant?
- Is a standard library type or established crate already enough?

## References

- Read [rust-patterns-summary.md](references/rust-patterns-summary.md) for a
  compact summary of the Rust Design Patterns book section and quick
  pattern-selection guidance.
- Pull in additional official Rust docs only for the specific topic under
  change, such as the Rust Book, Rust Reference, Rustonomicon, standard library
  docs, or crate-specific documentation.
