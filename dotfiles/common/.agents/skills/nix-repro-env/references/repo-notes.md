# Repo Notes

These notes apply to `/Users/khrore/nix-config` and similar host-oriented flakes.

## Current Shape

- The flake primarily exposes `nixosConfigurations` and `darwinConfigurations`.
- It does not obviously expose `devShells`, `apps`, or generic runnable `packages` at the top level.
- It uses a private `secrets` input fetched over SSH.

## Implications

- Do not assume `nix develop .` is valid here; inspect first.
- Reproducible execution may be blocked on SSH access to the private `secrets` input.
- Many useful commands in this repo are host-build commands such as:
  - `nix flake check`
  - `nixos-rebuild build --flake .#dev-4`
  - `nixos-rebuild build --flake .#nixos`
  - `darwin-rebuild build --flake .#macix`

## Reporting

When answering in this repo:

- mention that the flake is host-configuration-oriented
- distinguish Nix CLI environment usage from host rebuild workflows
- call out the private input if evaluation or builds fail on a machine without credentials
