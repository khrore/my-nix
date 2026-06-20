# AGENTS.md - Codex Policy Kernel

## Implementation Principles

For behavior-changing work, validate the implementation against these principles:

- **DRY**: keep each piece of knowledge in one clear place; avoid duplicated logic that can drift.
- **SRP**: keep each module, type, function, or command focused on one reason to change.
- **KISS**: choose the simplest design that satisfies the requirement without needless abstraction.
- **Open/Closed**: prefer extending behavior through stable boundaries instead of rewriting proven code.

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
