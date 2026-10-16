# Hyprland Lua migration

The desktop targets **Hyprland 0.56.2** from nixpkgs revision
`7fd4004d0511991fff3a0524856a9be09e28c5f0`. Both nixpkgs inputs already pointed
to this revision at implementation start; no lock update was needed. Other inputs
were preserved. Linux display guards, UWSM and the matching desktop portal remain
owned by the existing NixOS module.

Use the [0.56 configuration documentation](https://wiki.hypr.land/0.56.0/Configuring/Start/).
Hyprlock, Hypridle, Hyprsunset and the portal still use their own `.conf` files.
Shell helper names and arguments are preserved; Hyprland operations use Lua IPC.

## Configuration ownership

`~/.config/hypr/hyprland.lua` loads shared options, ordered application rules,
bindings and startup handlers from `$LINUX_SESSION_ROOT/default/hypr`, then the
selected `current/theme/hyprland.lua`, then personal Lua overrides. The session
root falls back to `~/.local/share/linux-desktop`; personal overrides use
`$XDG_CONFIG_HOME/hypr`, falling back to `~/.config/hypr`.

Hyprland's protected `require` registers loaded files for reload. Mandatory files
are not silently skipped. Normal reload recreates the Lua state and removes old
bindings and handlers. Startup commands run on `hyprland.start`, so reload and
theme changes do not launch additional services.

The small `runtime.lua` module exposes `desktop` operations to shell helpers.
Use `desktop.monitor({ ... })` for personal monitor rules: it also remembers
fallback/description options when a runtime scaling operation needs an exact
output rule. Other settings use ordinary `hl.config`, `hl.window_rule`, etc.
Toolkit exports live in `~/.config/uwsm/env`; Hyprland-specific exports live in
`env-hyprland`. These exports require a new UWSM login to take effect.

A theme can provide `hyprland.lua`, or obtain it from the built-in palette template
`hyprland.lua.tpl`. User templates have priority over built-in templates; an
explicit theme config has priority over templates. User `.conf` themes/templates
are rejected with a migration message. Each staged Lua theme is checked with the
real compositor before replacing the selected directory or its name. A failed
check leaves the previous theme in place. Optional application integrations are
best-effort and report their failures after the theme has been installed.

## Intentional fixes

| Before | After |
| --- | --- |
| Repeating ALT did not add a modifier; multiple actions fired for one key | Separate combinations below; 138 unique described bindings |
| `SUPER+ALT+K` proposed for the menu was also occupied by grouping | Menu uses `SUPER+CTRL+ALT+K`; existing window/group navigation is retained |
| Pop-window used a malformed multi-argument batch and could toggle an already floating window back to tiled | All operations target one captured window; explicit float/pin state, size and position; no active window is a no-op |
| Gap toggle always restored `10/5/2` | Restore final themed/personal values, including asymmetric gaps and Lumon's `16/8/2`; reload resets toggle state |
| Scaling replaced monitor position/options and announced success even on rejection | Preserve configured options and live position/transform; restore temporary notification state; verify actual scale and restore the old rule on timeout |
| Screensavers raced asynchronous launches by repeatedly changing monitor focus | Launch with explicit monitor/workspace rules; skip mirrored outputs; restore cursor visibility on exit |
| Floating-window tag was assigned after its float/center/size effects | Assign the tag first; verified with a real `local.terminal` window |
| DaVinci Resolve rules existed but were never imported | Include the existing rules in the explicit app list |
| Polkit attempted to launch from an unavailable `/usr/lib` path | Use the already working UWSM/XDG-autostart agent |
| Lua keycodes were absent from Hyprland 0.56.2 JSON IPC | Menu recovers `code:NN` from text IPC; all actions carry descriptions |
| Mass environment imports and explicit XDG session exports duplicated UWSM | Let UWSM own session exports; retain toolkit/cursor values in its env files |

Changed combinations (numeric positions retain the original physical keycodes):

| Action | Combination |
| --- | --- |
| Silent move to workspace 1–10 | SUPER+ALT+SHIFT+[1–0] |
| Binding menu | SUPER+CTRL+ALT+K |
| Color picker | SUPER+ALT+PRINT |
| Invoke / restore last notification | SUPER+ALT+COMMA / SUPER+ALT+SHIFT+COMMA |
| Show time | SUPER+CTRL+ALT+T |
| Reset zoom | SUPER+CTRL+ALT+Z |
| Next grouped window, previously conflicting with lock | SUPER+CTRL+ALT+L |

ALT+P is unassigned, as requested in the migration plan. The upstream removal was
specifically `dwindle:pseudotile`; the 0.56.2 API still contains a pseudo dispatcher,
so removal of the binding should not be interpreted as removal of that API.

## Validation and remaining hardware checks

Run `python3 tests/hyprland/check.py --integration` from a Wayland session.
The runner uses temporary HOME/XDG directories, a private D-Bus session and its
own compositor IPC signature. Startup commands and theme integration effects are
intercepted; the user's services and selected theme are not restarted. Test
windows use Alacritty. Without `--integration`, it runs parser and regression
checks only. Python, Hyprland, Lua/LuaJIT, jq and the normal desktop helper tools
must be available.

Validated on 2026-10-14:

- Real Hyprland 0.56.2 parser: complete configuration with all **19** built-in themes.
- User-template precedence; valid theme installation; invalid and legacy theme
  rejection; missing mandatory module; previous theme retained on rejection.
- Real isolated compositor: 138 unique described bindings, effective floating
  rules, pop/pin/size, opacity dispatch, dwindle/scrolling, silent workspace move,
  focus/group operations, gap/aspect toggles, binding menu, live theme change and
  three normal reloads without duplicate bindings or startup commands.
- Runtime regressions: themed/asymmetric gap restoration, exact pop target,
  failure propagation, monitor-option preservation and notification-state cleanup,
  per-output screensaver rules, rejected-scale rollback without a success notice,
  shell argument validation and Lua/transport error handling.
- StyLua, Python Ruff checks, Bash syntax, ShellCheck for migrated helpers,
  relevant Nix formatting and `git diff --check`.
- `nix flake check`; NixOS build; evaluation of `vlinix` and `macix` derivations.

**Environment limitation:** the nested headless output stayed at 0×0 and could not
commit a real display mode. Successful physical scaling, transform/HDR/VRR/mirror
behaviour, physical keyboard/touchpad input, media keys, real screensaver exit,
lock/unlock, suspend/resume, DPMS and portal screen sharing require checks after
application. They are not counted as passed. Darwin evaluation succeeded, but a
Darwin build was unavailable because this Linux host has no configured builders.

**Pre-existing warnings:** ShellCheck reports SC2155 in three existing webcam
menu declarations and SC1090 for the menu's user-extension source. The migration
adds no warnings to those lines; other changed helpers pass ShellCheck.

## Apply from a TTY; keep the current session unchanged until then

Do not relink from the implementation worktree into the running desktop. Once the
changes are reviewed, export/apply the complete diff to the normal configuration
checkout at the recorded base. The implementation worktree's staged changes can
be exported using `git diff HEAD --binary`. Preserve any unrelated local changes;
`git apply --index` should fail rather than force a conflicting patch.

1. Set `NIXOS_CONFIG_ROOT` to the checkout that will permanently own the dotfiles.
   Back up the current config, runtime theme, link manifest and previous Git/NixOS
   revision before applying the patch. Dereference config symlinks so the backup
   contains the old data independently of the checkout. For example:

   ```bash
   migration_backup="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland-migration/$(date +%Y%m%d-%H%M%S)"
   mkdir -p "$migration_backup"
   cp -aL "${XDG_CONFIG_HOME:-$HOME/.config}/hypr" "$migration_backup/hypr"
   cp -aL "${XDG_CONFIG_HOME:-$HOME/.config}/uwsm" "$migration_backup/uwsm"
   cp -aL "${LINUX_SESSION_ROOT:-$HOME/.local/share/linux-desktop}/current" "$migration_backup/current"
   cp -a "${XDG_STATE_HOME:-$HOME/.local/state}/link-dotfiles" "$migration_backup/link-dotfiles"
   git -C "$NIXOS_CONFIG_ROOT" rev-parse HEAD > "$migration_backup/git-revision"
   readlink -f /run/current-system > "$migration_backup/system-path"
   ```

2. Exit the desktop through `uwsm stop` and continue from a TTY. This avoids live
   auto-reload while old linked `.conf` files are replaced. Apply the reviewed patch,
   then run `sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_ROOT#nixos"`.
3. Run `link-dotfiles` with the permanent `NIXOS_CONFIG_ROOT`. Check its warnings:
   existing ordinary files are intentionally not overwritten. Migrate any personal
   ordinary configs and user theme/templates to Lua before continuing.
4. Regenerate the **existing runtime theme**, which linking deliberately preserves:

   ```bash
   theme-set "$(cat "${LINUX_SESSION_ROOT:-$HOME/.local/share/linux-desktop}/current/theme.name")"
   Hyprland --verify-config --config "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua"
   ```

   From a TTY, `theme-set` prepares the verified theme and skips desktop effects
   when no Hyprland instance is reachable. Verify the file and selected name before
   login. The next UWSM session loads the new theme and environment.

5. Start a new Hyprland UWSM session. Require empty `hyprctl configerrors`, verify
   the binding menu and toolkit environment, then perform the hardware checks above.

## If the session shows an autogenerated configuration

After replacing the linked legacy files, a running session may retain the cached
legacy configuration path. The new main file is `~/.config/hypr/hyprland.lua`.
First ensure the selected runtime theme also has `hyprland.lua` (regenerate it
with `theme-set` if needed) and verify the full main config. To switch the cached
configuration backend once without restarting applications:

```bash
Hyprland --verify-config --config "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua"
hyprctl reload full-reset
hyprctl configerrors
```

Use ordinary `hyprctl reload` for subsequent edits. Successful loading has
`autogenerated = 0` and 138 bindings. Window focus is ALT+H/J/K/L (left/down/up/right);
the binding menu is SUPER+CTRL+ALT+K. The existing runtime theme directory is
preserved by `link-dotfiles`, so relinking alone does not migrate its `.conf` file.

## Roll back

From a TTY, reverse only the migration changes in the checkout (for an applied
patch, `git apply --reverse --index` with the same patch), or return to the saved
revision if it contains all prior work. Run the restored `link-dotfiles` to remove
managed Lua links and restore the `.conf` links. Preserve ordinary user configs;
restore the saved `hypr` and `uwsm` directories where needed.

Replace the runtime `current` directory with the backed-up directory rather than
merging files from two theme formats. Keep the failed directory for diagnosis.
Restore the previous NixOS generation with `sudo nixos-rebuild switch --rollback`,
or boot it from the boot menu, then start a new UWSM session. Keep the migration
backup and old generation until the hardware checks have passed.
