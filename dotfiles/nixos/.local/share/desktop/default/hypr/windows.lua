-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- Hyprland 0.53+ syntax
hl.window_rule({ name = "windows-1", match = { class = ".*" }, suppress_event = "maximize" })

-- Tag all windows for default opacity (apps can override with -default-opacity tag)
hl.window_rule({ name = "windows-2", match = { class = ".*" }, tag = "+default-opacity" })

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "windows-3",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

-- App-specific tweaks (may remove default-opacity tag)
require(
	(os.getenv("DESKTOP_ROOT") or os.getenv("LINUX_SESSION_ROOT") or (os.getenv("HOME") .. "/.local/share/desktop"))
		.. "/default/hypr/apps.lua"
)

-- Apply default opacity after apps have had a chance to opt out
hl.window_rule({ name = "windows-4", match = { tag = "default-opacity" }, opacity = "1 1" })

-- Explicit opt-in transparency, toggled by Super+Backspace.
hl.window_rule({
	name = "manual-transparency",
	match = { tag = "manual-transparency" },
	opacity = "0.9 0.9",
})
