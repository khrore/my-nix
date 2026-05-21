---
name: nix-repro-env
description: Use when Codex needs to inspect flake outputs, choose between `nix run`, `nix develop`, and `nix shell`, execute commands in a pinned Nix environment, or diagnose reproducibility and evaluation issues in a flake-based workflow. Activate for Nix CLI environment usage, dev shell entry, command routing, and failures caused by missing attrs, wrong systems, lockfile drift, private inputs, or impurity.
---

# Nix Repro Env

Use Nix CLI entrypoints deliberately so commands run in a reproducible environment and the chosen flake output is explicit.

## Quick Start

- Inspect the flake before running anything substantial. Read `flake.nix`, `flake.lock`, and any repo docs that define shells, apps, packages, or checks.
- Prefer pinned flake entrypoints over ambient host tools.
- Choose the narrowest command:
  - `nix run` for one executable or app
  - `nix develop` for multi-step work or a real dev environment
  - `nix shell` for temporary package access when no suitable dev shell exists
- Avoid `--impure` unless the task explicitly requires host environment leakage.
- Report the exact flake ref and attr path that were used.

## Workflow

1. Inspect available outputs.
   - Use `scripts/inspect-flake-outputs.sh [flake-ref]` for a quick summary.
   - If the repo is local, read `flake.nix` directly so you can spot private inputs, host-only outputs, or absent `devShells`.
2. Pick the execution path.
   - Read `references/command-selection.md` when the right entrypoint is unclear.
3. Run or explain the command.
   - Use `scripts/run-in-devshell.sh <flake-ref> <devshell-attr> -- <command...>` for multi-step tool execution in a selected shell.
   - Use plain `nix run` directly when the task is clearly app- or package-scoped.
4. If it fails, classify the failure.
   - Read `references/debugging.md` for evaluation, attr, system, purity, and private-input failures.
5. Record reproducibility facts.
   - Use `scripts/repro-report.sh [flake-ref] [selected-attr]` when you need a concise execution report.

## Reference Map

Read only what is needed:

- `references/command-selection.md` for choosing `nix run` vs `nix develop` vs `nix shell`
- `references/repro-checklist.md` for the minimum reproducibility checks to mention in an answer
- `references/debugging.md` for common Nix CLI and flake failure modes
- `references/repo-notes.md` when the current repo is `/Users/khrore/nix-config` or follows the same host-oriented shape

## Quality Rules

- Prefer exact attrs over vague advice.
- Do not assume a dev shell exists; confirm it.
- Do not recommend `nix profile install` for task-local, reproducible execution.
- Do not hide impurity. If `--impure` is required, say why.
- Do not claim a command is reproducible unless the flake ref, system, and selected output are clear.
