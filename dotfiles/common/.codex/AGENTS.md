# AGENTS.md - Codex Policy Kernel

## Implementation Principles

For behavior-changing work, validate the implementation against these principles:

- **DRY**: keep each piece of knowledge in one clear place; avoid duplicated logic that can drift.
  - Look for existing places where the same decision is already represented before adding another one.
  - Consolidate shared behavior when duplication would make future changes easy to miss.
  - Avoid forced abstraction when code only looks similar but represents different intent.
- **SRP**: keep each module, type, function, or command focused on one reason to change.
  - Keep different kinds of responsibility distinct when they are likely to evolve independently.
  - Prefer changes that fit the existing ownership boundaries of the codebase.
  - When a change starts touching unrelated concerns, split the work into clearer units.
- **KISS**: choose the simplest design that satisfies the requirement without needless abstraction.
  - Prefer the direct solution that matches the current shape of the system.
  - Add indirection only when it makes the code easier to understand, test, or extend now.
  - Avoid solving possible future problems unless the current requirement makes them real.
- **Open/Closed**: prefer extending behavior through stable boundaries instead of rewriting proven code.
  - Follow existing extension patterns when the codebase already provides one.
  - Preserve stable contracts unless the requested behavior explicitly changes them.
  - Isolate variation so existing behavior remains easy to reason about.

## Validation Minimums

For behavior-changing work, validate in this order when applicable:

1. formatter check
1. linter check
1. type or LSP-equivalent check
1. build or compile check
1. targeted tests for changed behavior
1. broader tests when risk or scope requires

Classify failures as one of:

- introduced
- pre-existing
- environment
- scope-expanding

Do not claim success without command evidence.

Linter warnings are not ignorable by default. Treat any linter warning on touched code as a failure that must be fixed or explicitly escalated with justification before handoff or completion.
