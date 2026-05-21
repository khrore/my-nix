# Debugging

Use this reference when a Nix CLI environment command fails or reproducibility is unclear.

## Missing Attrs

Symptoms:

- `does not provide attribute`
- `flake does not provide attribute 'devShells.<system>...'`

Checks:

- inspect `flake.nix`
- run `scripts/inspect-flake-outputs.sh [flake-ref]`
- confirm whether the target is actually under `packages`, `apps`, `devShells`, `checks`, `nixosConfigurations`, or `darwinConfigurations`

Typical fix:

- route to the correct command and attr instead of forcing the wrong interface

## Wrong System

Symptoms:

- attr exists for another system but not the current one
- `aarch64-darwin` vs `x86_64-linux` mismatches

Checks:

- confirm the current system
- inspect whether the output is system-scoped

Typical fix:

- choose the system-appropriate attr or explain that the repo does not expose one for the current host

## Private Inputs

Symptoms:

- fetch failures for SSH-backed or private Git inputs
- evaluation fails on machines without the required credentials

Checks:

- inspect `flake.nix` inputs for `git+ssh` or private repositories
- mention SSH agent and credential requirements explicitly

Typical fix:

- classify the failure as environment or access-related, not a generic flake bug

## Impurity

Symptoms:

- command only works with `--impure`
- behavior depends on ambient variables, host SDKs, or paths outside the flake

Checks:

- identify which external input is leaking in
- decide whether the task genuinely requires impurity

Typical fix:

- represent the dependency in the flake if possible; otherwise state why impurity is required

## Dirty Tree or Lock Drift

Symptoms:

- local behavior differs from another machine
- evaluation uses uncommitted local changes

Checks:

- confirm whether the flake ref is a local path
- confirm whether `flake.lock` is present and committed

Typical fix:

- state that the result depends on local, unlocked repo state
