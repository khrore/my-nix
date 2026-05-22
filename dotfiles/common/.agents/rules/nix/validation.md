# Nix Validation

For `.nix` and flake changes, prefer repository-specific checks first.

## Standard commands

1. Formatter: `nix fmt`, or the formatter configured by the flake.
1. Linter: `statix check` and `deadnix` when available.
1. Evaluation/build: `nix flake check` for flake repositories.
1. Scoped builds: build the touched host, package, dev shell, or app output.

## This nix-config repository

Use the smallest relevant command:

- Global flake validation: `nix flake check`
- Linux shared changes: `nixos-rebuild build --flake .#dev-4`
- Host `nixos` changes: `nixos-rebuild build --flake .#nixos`
- Darwin changes: `darwin-rebuild build --flake .#macix`

If private inputs or platform-specific commands block validation, report the
command attempted and classify the failure as `environment` unless the change
introduced it.
