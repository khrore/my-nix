hl.window_rule({
	name = "system-4",
	match = {
		class = "(local.wiremix|local.btop|local.terminal|local.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|About|TUI.float|imv|mpv)",
	},
	tag = "+floating-window",
})
hl.window_rule({
	name = "system-5",
	match = {
		class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)",
		title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
	},
	tag = "+floating-window",
})
-- Floating windows
hl.window_rule({ name = "system-1", match = { tag = "floating-window" }, float = true })
hl.window_rule({ name = "system-2", match = { tag = "floating-window" }, center = true })
hl.window_rule({ name = "system-3", match = { tag = "floating-window" }, size = "875 600" })

hl.window_rule({ name = "system-6", match = { class = "org.gnome.Calculator" }, float = true })

-- Fullscreen screensaver
hl.window_rule({ name = "system-7", match = { class = "local.screensaver" }, fullscreen = true })
hl.window_rule({ name = "system-8", match = { class = "local.screensaver" }, float = true })
hl.window_rule({ name = "system-9", match = { class = "local.screensaver" }, animation = "slide" })

-- No transparency on media windows
hl.window_rule({
	name = "system-10",
	match = {
		class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
	},
	tag = "-default-opacity",
})
hl.window_rule({
	name = "system-11",
	match = {
		class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
	},
	opacity = "1 1",
})

-- Popped window rounding
hl.window_rule({ name = "system-12", match = { tag = "pop" }, rounding = 8 })

-- Prevent idle while open
hl.window_rule({ name = "system-13", match = { tag = "noidle" }, idle_inhibit = "always" })
