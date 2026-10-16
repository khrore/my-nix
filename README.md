# Nix Config

Personal multi-host Nix flake for Linux and macOS. It uses Nix for
system-level state and package installation, while keeping dotfiles linkable as
a separate user-level layer instead of tightly coupling them to Home Manager.

The Linux desktop is inspired by [Omarchy](https://github.com/omacom/omarchy).

## What This Repo Defines

- NixOS hosts: `nixos`, `vlinix`
- Darwin host: `macix`
- Shared system layer in `hosts/common`
- Shared Home Manager layer in `home`
- Shared helper library in `lib`
- Shared and platform-specific dotfiles in `dotfiles`
- Runtime configs and hidden agent files under `dotfiles/common`

The flake entrypoint is [flake.nix](./flake.nix). Host definitions are wired
into `nixosConfigurations` and `darwinConfigurations`, with common
`specialArgs` such as `hostName`, `username`, `system`, `pkgs-unstable`, and
`mylib`.

## Main Stack

This config is built around:

- `nixpkgs` and `nixpkgs-unstable` for packages
- `nix-darwin` for macOS system management
- Home Manager mainly for user-level package installation
- `disko` for Linux disk layout
- `agenix` plus a private `secrets` flake for secret material
- Homebrew on macOS for native apps that are better managed outside Nix

The helper library in [lib/default.nix](./lib/default.nix) provides:

- `scanPaths` to auto-import module directories
- `scanFiles` and `linkDotfiles` for dotfile discovery/merge helpers
- Platform predicates for Linux/Darwin splits

## Main Tasks This Config Covers

- Bootstrap a new workstation
- Manage Linux and macOS machines from one flake
- Install shells, editors, formatters, linters, and language servers
- Configure a Linux desktop around Hyprland and Wayland tools
- Configure a macOS machine with `nix-darwin` defaults and Homebrew apps
- Install packages and root-related system configuration
- Link shared dotfiles into `$HOME` independently
- Provide AI and agent tooling such as `opencode`, `qwen-code`, and runtime
  config files

## Tooling Included

The shared Home Manager package bundles are under [home/pkgs](./home/pkgs).

Highlights:

- Shell and CLI: `atuin`, `zoxide`, `starship`, `tmux`, `fzf`, `bat`,
  `ripgrep`, `fd`, `eza`
- Editors and terminals: `neovim`, `kitty`, `ghostty`, `zed-editor`
- AI tools: `opencode`, `qwen-code`, `promptfoo`, plus macOS casks for
  `codex`, `claude-code`, and `chatgpt-atlas`
- Dev tooling: `clang`, `nil`, `nixd`, `nixfmt`, `ruff`, `basedpyright`,
  `bash-language-server`, `vtsls`, `eslint`, `prettierd`, `cmake`, `gnumake`
- Network and ops: `git`, `gh`, `mtr`, `iperf3`, `socat`, `nmap`, `openssl`
- Linux desktop: `hyprland`, `waybar`, `dunst`, `rofi`, `hyprlock`,
  `hypridle`, `hyprpaper`, `localsend`, `throne`
- macOS native apps through Homebrew: `aerospace`, `docker-desktop`,
  `ghostty`, `zed`, `codex`, `claude-code`, `zen@twilight`, `chatgpt-atlas`,
  and selected GUI apps

## Repo Structure

- [hosts](./hosts): host entrypoints and shared system modules
- [home](./home): Home Manager entrypoint, package bundles, and dotfile
  activation
- [lib](./lib): helper functions used across the flake
- [dotfiles](./dotfiles): source files linked into the user home directory

Composition flow:

1. `flake.nix` selects a host.
1. The host imports `hosts/common/default.nix`.
1. `hosts/common/default.nix` imports shared system modules and
   `home/default.nix`.
1. `home/default.nix` imports all package bundles and the `link-dotfiles`
   helper definition.
1. Dotfiles are linked from `dotfiles/common` and the active platform directory
   when activation runs or when `link-dotfiles` is called manually.

## Using This In Your Own Environment

This repo is personal, so using it unchanged on another machine will usually
fail unless you adapt it. The main blockers are the private `secrets` input,
host-specific hardware modules, usernames, disk layout, and some
machine-specific assumptions.

Recommended path:

1. Fork or copy the repository.
1. Update the host map in [flake.nix](./flake.nix) with your own host name,
   username, and target system.
1. Remove or replace the private `secrets` input if you do not have access to
   `git@github.com/khrore/nixrets.git`.
1. Replace Linux hardware files and `disko` definitions under your host
   directory.
1. Review shared modules in [hosts/common](./hosts/common) and disable anything
   you do not want globally, especially Hyprland, Docker, `localsend`,
   `throne`, SSH, and age secret paths.
1. Trim or replace package bundles in [home/pkgs](./home/pkgs) to match your
   workload.
1. Add or replace files in [dotfiles](./dotfiles) with your own configs.

## Bootstrap Commands

### NixOS

After cloning the repo and entering it, or setting `NIXOS_CONFIG_ROOT` to the
checkout path:

```bash
sudo nixos-rebuild switch --flake .#your-host
```

For first install on bare metal, you will also need your own hardware config
and, if you keep it, a matching `disko` layout.

### macOS

Install Nix and `nix-darwin`, then apply:

```bash
darwin-rebuild switch --flake .#your-host
```

The Darwin host in this repo also enables Homebrew integration, so the initial
activation expects Homebrew-compatible settings and a valid primary user.

## Dotfiles Behavior

[home/link-dotfiles.nix](./home/link-dotfiles.nix) installs a `link-dotfiles`
command and also hooks it into Home Manager activation. The dotfiles are not
tightly coupled to Home Manager after that point: you can run `link-dotfiles`
manually at any time to relink configs without reapplying the full Nix
configuration.

At runtime the script searches upward from:

- `$NIXOS_CONFIG_ROOT`
- the current working directory (`$PWD`)
- `$XDG_CONFIG_HOME`, falling back to `$HOME/.config`
- `$HOME`
- any `flake.nix` found under `$HOME` within depth 3

Platform-specific files override `dotfiles/common` by relative path. Existing
non-symlink files in `$HOME` are left in place and reported as warnings.
The Linux theme files under `current/` are copied only when no theme has been
selected yet; later `link-dotfiles` runs leave the selected theme intact.

Manual usage:

```bash
link-dotfiles
```

## Validation

Smallest relevant checks after changes:

```bash
nix flake check
nixos-rebuild build --flake .#nixos
darwin-rebuild build --flake .#macix
```

Some evaluation paths may still require access to the private `secrets` flake.

## Agent Runtime Files

Runtime-specific configs live under hidden files in `dotfiles/common`, including
OpenCode, Codex, Claude, Cursor, Pi, and shared `.agents` rules/skills.

## Hyprland Lua desktop

The Linux desktop targets Hyprland **0.56.2**, pinned through nixpkgs revision
`7fd4004d0511991fff3a0524856a9be09e28c5f0`. Configuration now starts at
`~/.config/hypr/hyprland.lua`: shared defaults and application rules load first,
then the generated Lua theme, then personal overrides. UWSM owns environment
exports and session startup; other Hypr tools retain their `.conf` formats.

The migration also fixes conflicting shortcuts, window pop/pin operations,
themed gap restoration, per-monitor screensaver launching, floating-rule order,
and theme validation. The binding menu is now **SUPER+CTRL+ALT+K**; use it to see
all combinations. Themes are checked before replacing the selected runtime theme.

The [migration guide](docs/hyprland-lua-migration.md) records the changed shortcuts,
checks and limitations, plus TTY application and rollback instructions. All 19
built-in themes passed the real compositor parser. An isolated compositor checked
window operations, layouts, bindings, theme switching and repeat reloads. Physical
monitor scaling, input, suspend/lock and screen sharing still require post-login
checks. The implementation does not switch the running desktop.

Repeat the parser/regression checks with:

```bash
python3 tests/hyprland/check.py
python3 tests/hyprland/check.py --integration
```
