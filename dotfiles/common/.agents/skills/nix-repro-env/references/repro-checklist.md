# Reproducibility Checklist

When describing or validating a Nix CLI environment, confirm the minimum facts below.

## Minimum Facts

- flake ref used, such as `.` or `github:owner/repo`
- selected output attr, such as `.#devShells.x86_64-linux.default` or `.#fmt`
- system, such as `x86_64-linux` or `aarch64-darwin`
- whether a `flake.lock` is present and relevant
- whether the command relied on `--impure`

## Local Repo Checks

For local flakes:

- read `flake.nix`
- note whether the repo is dirty if that matters to the result
- check whether required inputs are private or fetched over SSH
- confirm whether the flake defines `devShells`, `packages`, `apps`, or only system configurations

## Reporting Pattern

Prefer a short statement like:

`Used <flake-ref> with attr <attr> on <system>; no impurity was required.`

If impurity or ambient dependencies were required, say so explicitly.

## Warning Signs

- advice assumes a dev shell exists without inspecting outputs
- advice uses host-installed tools instead of flake-pinned tools
- the command omits the attr even though the flake exposes multiple plausible targets
- the task is blocked on a private input and the answer ignores it
