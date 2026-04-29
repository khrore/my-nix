# AGENTS.md - Codex Policy Kernel

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
