# Nix Config

Personal multi-host Nix flake for Linux and macOS. It uses Nix for
system-level state and package installation, while keeping dotfiles linkable as
a separate user-level layer instead of tightly coupling them to Home Manager.

The Linux desktop is inspired by [Omarchy](https://github.com/omacom/omarchy).

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

## macOS Desktop and Dark Themes

Apply the configuration with `sudo darwin-rebuild switch --flake path:.#macix`, then
run `link-dotfiles` from the checkout if needed. Run
`aerospace reload-config --dry-run --warnings-as-errors` before reloading
AeroSpace with `aerospace reload-config`. AeroSpace needs Accessibility access
in System Settings. The launcher at `~/.local/bin/mac-desktop` is installed by
Home Manager and supplies its own Nix runtime; it does not source shell startup
files. Ordinary Ghostty windows retain the existing floating workaround.

Command shortcuts stay available to applications. Desktop shortcuts use Option:

| Shortcut | Action |
| --- | --- |
| Option-H/J/K/L | Focus left/down/up/right |
| Option-Shift-H/J/K/L | Swap windows left/down/up/right |
| Option-1…9/0 | Select workspace 1…10 |
| Option-Shift-1…9/0 | Move window and follow it |
| Option-Control-Shift-1…9/0 | Move window without following |
| Option-T | Toggle floating/tiling |
| Option-F | Toggle AeroSpace fullscreen |
| Option-Control-Shift-F | Toggle native macOS fullscreen |
| Option-W | Close window |
| Option-Minus/Equal | Resize window |
| Option-Slash/Comma | Tiles/accordion layout |
| Option-R | Reload AeroSpace configuration |
| Option-Return | Open Ghostty |
| Option-Shift-Return or Option-Shift-B | Open Zen |
| Option-Shift-F | Open Yazi in a new Ghostty instance |
| Option-Shift-N/M/O | Open Zed/Spotify/Obsidian |
| Option-Shift-Slash | Open Bitwarden |
| Option-Control-Shift-Space | Choose a theme in a native list dialog |
| Option-Control-Space | Cycle the selected theme's wallpaper |

In System Settings → Keyboard → Text Input → Edit, add English and Russian
input sources, then enable **Use the Caps Lock key to switch to and from the
last used Latin input source**. Input sources remain user-managed; the rebuild
does not overwrite them.

The shared theme commands work on Linux and macOS:

```bash
theme-list
theme-current
theme-set kanagawa
theme-refresh
theme-bg-next
theme-bg-set /absolute/path/to/image.jpg
```

On macOS, `theme-pick` opens the native selector; cancelling leaves the theme
unchanged. Available palettes are Gruvbox, Kanagawa, Nord, Everforest,
Catppuccin, and Tokyo Night. Themes marked with `light.mode` are hidden and
rejected. macOS appearance remains Dark; no automatic light/dark scheduling is
configured.

Theme assets and commands live in the common dotfile layer. Linux compositor,
service, and toolkit integrations remain Linux-only. The canonical runtime path is
`~/.local/share/desktop`, with the `DESKTOP_ROOT` override and customizations
under `~/.config/desktop`. User theme files
overlay built-in assets; user templates override built-in templates unless the
theme supplies that output directly. Rebuilds and relinking preserve the
selected theme; Gruvbox is seeded only on first use. Generated app themes are
mutable files, and existing user-owned dotfiles are left in place with a warning.

The macOS switcher updates Ghostty, Kitty, Alacritty, Neovim, Zed, Yazi, Zellij,
btop, Codex, and wallpaper on connected desktops. System Events may request
Automation permission when first setting appearance or wallpaper. A theme
without wallpapers leaves the current wallpaper unchanged. macOS window chrome
keeps its native styling. Browser, Telegram, Obsidian, VS Code, and toolkit
theme integrations remain Linux-only for this update.

Zed watches its named theme, Neovim watches the selected theme, and Yazi receives
a reload event. Terminal and btop reloads use their configuration reload signals.
If a focused Ghostty window keeps its previous colors, press Command-R. Zellij
may require reopening an existing session to display the new palette. Codex
settings are saved while preserving unrelated settings and respecting
`CODEX_HOME`; restart Codex Desktop to apply them. The switcher does not close
applications. It reports failed integrations, continues with the others, and
returns a nonzero status when an enabled integration fails.

The shared app theme is named **Desktop** (`desktop` for Zellij and Yazi).
`LINUX_SESSION_ROOT` remains a fallback for `DESKTOP_ROOT`. The dotfile linker
does not migrate legacy directories or rewrite user-owned settings.
