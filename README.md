# Nix desktop

Personal NixOS and macOS configurations with coordinated dark themes, tiling
desktops, and shared developer tools.

**Hyprland on Linux · AeroSpace on macOS · One flake for multiple machines**

Nix manages system settings and packages. Home Manager installs the user
environment and links dotfiles from this checkout, so you can edit them directly
and relink them without rebuilding the system.

[Highlights](#highlights) · [Themes](#themes) · [Explore the config](#explore-the-config) ·
[Get started](#get-started) · [Reference](#reference)

## Highlights

- **Coordinated themes.** Switch palettes across terminals, editors, and desktop
  tools, with wallpaper controls and platform-specific integrations.
- **Keyboard-driven desktops.** Hyprland and Wayland tools on Linux; AeroSpace
  workspaces and application shortcuts on macOS.
- **Multiple machines, shared configuration.** NixOS and nix-darwin hosts share
  modules, package bundles, and a common dotfile layer.
- **Editable dotfiles.** Platform-specific overrides and a standalone
  `link-dotfiles` command keep everyday config changes close at hand.

## Themes

The shared theme commands work on Linux and macOS once the environment is installed:

```bash
theme-list
theme-current
theme-set kanagawa
theme-refresh
theme-bg-next
theme-bg-set /absolute/path/to/image.jpg
```

Available palettes are **Gruvbox**, **Kanagawa**, **Nord**, **Everforest**,
**Catppuccin**, and **Tokyo Night**. On macOS, `theme-pick` opens a native
selector; cancelling leaves the theme unchanged.

## Explore the config

Looking for ideas for your own setup? Start with a specific part:

| Area                | Configuration                                                                                                                                                            |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Linux desktop       | [Hyprland](./dotfiles/nixos/.config/hypr), [Wayland tools and desktop configs](./dotfiles/nixos/.config)                                                                 |
| macOS desktop       | [AeroSpace shortcuts and workspaces](./dotfiles/darwin/.config/aerospace/aerospace.toml)                                                                                 |
| Themes              | [Shared palettes and assets](./dotfiles/common/.local/share/desktop/themes), [theme commands](./dotfiles/common/.local/share/desktop/bin)                                |
| Terminals and shell | [Ghostty](./dotfiles/common/.config/ghostty), [Kitty](./dotfiles/common/.config/kitty), [Zsh](./dotfiles/common/.config/zsh), [Zellij](./dotfiles/common/.config/zellij) |
| Editors             | [Neovim](./dotfiles/common/.config/nvim), [Zed](./dotfiles/common/.config/zed)                                                                                           |
| Nix environment     | [Host definitions](./flake.nix), [shared system modules](./hosts/common), [package bundles](./home/pkgs)                                                                 |

These configs share theme files, commands, and installed packages. Review those
dependencies when adapting an individual piece.

## Get started

This is a personal configuration to adapt, with host-specific hardware, disk
layouts, usernames, and a private secrets input. Review the steps below before
applying it to your machine.

### Adapt it to your machine

1. Fork or copy the repository.
1. Update the host map in [flake.nix](./flake.nix) with your own host name,
   username, and target system.
1. Remove or replace the private `secrets` input and its
   `inputs.secrets.nixosModules.default` / `inputs.secrets.darwinModules.default`
   references in [flake.nix](./flake.nix). The input points to
   `git@github.com/khrore/nixrets.git`, which requires private access.
1. Replace Linux hardware files and `disko` definitions under your host
   directory.
1. Review shared modules in [hosts/common](./hosts/common) and disable anything
   you do not want globally, especially Hyprland, Docker, `localsend`,
   `throne`, SSH, and age secret paths.
1. Trim or replace package bundles in [home/pkgs](./home/pkgs) to match your
   workload.
1. Add or replace files in [dotfiles](./dotfiles) with your own configs.

### NixOS

After adapting the configuration, run this from the checkout, replacing
`your-host` with the host name you defined in `flake.nix`:

```bash
sudo nixos-rebuild switch --flake .#your-host
```

For first install on bare metal, you will also need your own hardware config
and, if you keep it, a matching `disko` layout.

### macOS

Install Nix and `nix-darwin`, then apply:

```bash
sudo darwin-rebuild switch --flake .#your-host
```

The Darwin host in this repo also enables Homebrew integration, so the initial
activation expects Homebrew-compatible settings and a valid primary user.

## Reference

<details>
<summary><strong>Repository layout and composition</strong></summary>

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

</details>

<details>
<summary><strong>Dotfile linking and existing files</strong></summary>

[home/link-dotfiles.nix](./home/link-dotfiles.nix) installs a `link-dotfiles`
command and also hooks it into Home Manager activation. The dotfiles are not
tightly coupled to Home Manager after that point: you can run `link-dotfiles`
manually at any time to relink configs without reapplying the full Nix
configuration.

At runtime the script searches upward from:

- `$NIXOS_CONFIG_ROOT`
- `$NIXOS_CONFIG`
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

</details>

<details>
<summary><strong>macOS setup and keyboard shortcuts</strong></summary>

After applying your adapted macOS configuration, run `link-dotfiles` from the
checkout if needed. Run
`aerospace reload-config --dry-run --warnings-as-errors` before reloading
AeroSpace with `aerospace reload-config`. AeroSpace needs Accessibility access
in System Settings. The launcher at `~/.local/bin/mac-desktop` is installed by
Home Manager and supplies its own Nix runtime; it does not source shell startup
files. Ordinary Ghostty windows retain the existing floating workaround.

Command shortcuts stay available to applications. Desktop shortcuts use Option:

| Shortcut                              | Action                                 |
| ------------------------------------- | -------------------------------------- |
| Option-H/J/K/L                        | Focus left/down/up/right               |
| Option-Shift-H/J/K/L                  | Swap windows left/down/up/right        |
| Option-1…9/0                          | Select workspace 1…10                  |
| Option-Shift-1…9/0                    | Move window and follow it              |
| Option-Control-Shift-1…9/0            | Move window without following          |
| Option-T                              | Toggle floating/tiling                 |
| Option-F                              | Toggle AeroSpace fullscreen            |
| Option-Control-Shift-F                | Toggle native macOS fullscreen         |
| Option-W                              | Close window                           |
| Option-Minus/Equal                    | Resize window                          |
| Option-Slash/Comma                    | Tiles/accordion layout                 |
| Option-R                              | Reload AeroSpace configuration         |
| Option-Return                         | Open Ghostty                           |
| Option-Shift-Return or Option-Shift-B | Open Zen                               |
| Option-Shift-F                        | Open Yazi in a new Ghostty instance    |
| Option-Shift-N/M/O                    | Open Zed/Spotify/Obsidian              |
| Option-Shift-Slash                    | Open Bitwarden                         |
| Option-Control-Shift-Space            | Choose a theme in a native list dialog |
| Option-Control-Space                  | Cycle the selected theme's wallpaper   |

In System Settings → Keyboard → Text Input → Edit, add English and Russian
input sources, then enable **Use the Caps Lock key to switch to and from the
last used Latin input source**. Input sources remain user-managed; the rebuild
does not overwrite them.

</details>

<details>
<summary><strong>Theme customization, app reloads, and platform differences</strong></summary>

Themes marked with `light.mode` are hidden and rejected. macOS appearance
remains Dark; no automatic light/dark scheduling is configured.

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

</details>

## Credits

The Linux desktop is inspired by [Omarchy](https://github.com/omacom/omarchy).
The setup builds on [NixOS](https://nixos.org/),
[nix-darwin](https://github.com/nix-darwin/nix-darwin),
[Home Manager](https://github.com/nix-community/home-manager),
[Hyprland](https://hypr.land/), and
[AeroSpace](https://github.com/nikitabobko/AeroSpace).

## License

Original code by khrore is available under the [MIT License](./LICENSE).
Third-party code, themes, wallpapers, and other assets retain their respective
licenses and attributions; the MIT license does not relicense those materials.
