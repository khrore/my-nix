# AGENTS.md - Codex Policy Kernel

Keep the user's desired outcome and constraints distinct from their diagnosis or proposed implementation, which may be hypotheses. Before behavior-changing work, briefly consider whether the requested change addresses the actual problem and mention a materially simpler or safer alternative when one is evident.

## Delegation and Context Management

For substantial tasks, act as coordinator and integrator, retaining ownership of requirements, shared decisions, and final validation.

- Proactively use subagents for bounded work when this improves context management, coverage, quality, or speed; do not wait for an explicit request.
- Delegate context-heavy exploration and log analysis early, even when sequential. Keep small tasks and tightly coupled steps in the main agent.
- Give each subagent a clear objective, constraints, scope, expected output, and completion criteria, with only the context needed.
- Parallelize independent work with non-overlapping file or module ownership. Tell workers they share the codebase and must preserve others' changes; agree on shared interfaces first.
- Continue useful, non-overlapping work while agents run. Avoid duplicating delegated work except for intentional independent checks.
- Request concise findings or changes, evidence and file references, checks performed, and unresolved issues rather than full logs or transcripts.
- Review delegated changes, verify critical claims, and run appropriate integration checks before completion. Scale agent count to the task and available concurrency; avoid unnecessary recursive delegation.

## Implementation Principles

When making technical decisions, do not give much weight on development cost. Instead, prefer quality, simplicity, robustness, scalability and long term maintability

Before implementing general-purpose functionality, check existing project dependencies and established libraries. Prefer a maintained library when it materially improves correctness or maintainability; explain the reason when choosing a custom implementation.

For behavior-changing work, use these principles as practical heuristics and balance them against each other:

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
  - Do not introduce extension points or indirection for hypothetical future needs.

## Documentation and Comments

- Do not create documentation, reports, or summary files unless explicitly requested.
- Update existing documentation only where changes make it inaccurate.
- Preserve each document's purpose and scope. Make only task-required corrections; do not expand, reorganize, or polish documentation unless explicitly requested.
- Keep README concise: project purpose, essential usage, and non-obvious constraints. Do not add directory trees, file inventories, implementation walkthroughs, or task summaries unless explicitly requested.
- Do not modify AGENTS.md or other agent-instruction files unless explicitly requested.
- Add code comments only to explain non-obvious reasons and constraints.

## Validation

Run relevant checks in an order that provides useful feedback quickly. Scale validation with the scope, risk, and reversibility of the change; broaden it when failures or unresolved uncertainty justify doing so.

Depending on the change, relevant checks may include:

- formatter checks
- linter checks
- type or LSP-equivalent checks
- build or compile checks
- targeted tests for changed behavior
- broader tests when risk or scope requires

Classify failures as one of:

- introduced
- pre-existing
- environment
- scope-expanding

Report the checks run and their results. If a relevant check cannot be run, explain why. Fix warnings introduced by the change; report pre-existing failures without expanding the task unless they block meaningful validation.
