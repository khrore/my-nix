# AGENTS.md - Codex Policy Kernel

## Validation Minimums

For any code-changing work, always verify changes before the final response with
the smallest relevant checks, in this order when applicable:

1. formatter check
1. linter check
1. type or LSP-equivalent check
1. build or compile check
1. scoped tests for changed behavior
1. broader tests when risk or scope requires

If a formatter, linter, type check, build, or scoped test command cannot be
identified or cannot be run, explicitly say so and classify the reason before
completion. Do not silently skip validation.

Use the loaded language rules and their Validation Toolchain Catalog to choose
commands by touched file extension. Prefer project-defined commands over generic
commands.

For behavior-changing non-code work, run the closest applicable validation
command for the touched system.

Classify failures as one of:

- introduced
- pre-existing
- environment
- scope-expanding

Do not claim success without command evidence.

Linter warnings are not ignorable by default. Treat any linter warning on
touched code as a failure that must be fixed or explicitly escalated with
justification before handoff or completion.
