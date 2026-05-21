# Command Selection

Use the smallest Nix CLI surface that satisfies the task.

## Decision Rule

1. Use `nix run` when the task is "execute one app or package entrypoint."
2. Use `nix develop` when the task needs multiple commands, an interactive shell, tool discovery, or build/test loops.
3. Use `nix shell` when the repo has no suitable dev shell and the request is just "make package X available temporarily."

## Prefer `nix run`

Choose `nix run` for:

- one executable exposed as an app or runnable package
- commands that should not inherit a broad shell environment
- cases where the exact runnable attr is known

Examples:

- `nix run .#formatter`
- `nix run nixpkgs#hello`

## Prefer `nix develop`

Choose `nix develop` for:

- multi-step workflows such as `configure`, `build`, `test`
- repos that publish `devShells`
- tasks needing PATH/toolchain setup across several commands
- investigation where a shell environment itself is part of the task

Examples:

- `nix develop .#default`
- `nix develop .#ci -c cargo test`

## Use `nix shell` Sparingly

Choose `nix shell` for:

- ad hoc package access outside a repo-defined shell
- simple one-off package availability such as `ripgrep`, `jq`, or `go`

Avoid it when:

- the repo already defines a `devShell`
- the user asked for a reproducible repo workflow rather than package access

## Avoid for This Skill

- `nix profile install`: mutates user state; not a task-local reproducible environment
- `nix-env`: legacy and stateful
- `--impure`: only use when the task explicitly depends on ambient variables or filesystem paths not represented in the flake
