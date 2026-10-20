-- Menus
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("launch-walker"), { description = "Launch apps" })
hl.bind("SUPER + CTRL + E", hl.dsp.exec_cmd("launch-walker -m symbols"), { description = "Emoji picker" })
hl.bind("SUPER + CTRL + C", hl.dsp.exec_cmd("menu capture"), { description = "Capture menu" })
hl.bind("SUPER + CTRL + O", hl.dsp.exec_cmd("menu toggle"), { description = "Toggle menu" })
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("menu"), { description = "Main menu" })
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("menu system"), { description = "System menu" })
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("menu system"), { description = "Power menu", locked = true })
hl.bind("SUPER + ALT + CTRL + K", hl.dsp.exec_cmd("menu-keybindings"), { description = "Show key bindings" })
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"), { description = "Calculator" })

-- Aesthetics
hl.bind("SUPER + SHIFT + SPACE", hl.dsp.exec_cmd("toggle-waybar"), { description = "Toggle top bar" })
hl.bind("SUPER + CTRL + SPACE", hl.dsp.exec_cmd("menu background"), { description = "Theme background menu" })
hl.bind("SUPER + SHIFT + CTRL + SPACE", hl.dsp.exec_cmd("menu theme"), { description = "Theme menu" })
hl.bind(
	"SUPER + BACKSPACE",
	hl.dsp.exec_cmd(
		'hyprland-eval \'local w = hl.get_active_window(); if w then desktop.dispatch(hl.dsp.window.set_prop({ window = w, prop = "opaque", value = "toggle" })) end\''
	),
	{ description = "Toggle window transparency" }
)
hl.bind(
	"SUPER + SHIFT + BACKSPACE",
	hl.dsp.exec_cmd("hyprland-window-gaps-toggle"),
	{ description = "Toggle window gaps" }
)
hl.bind(
	"SUPER + CTRL + BACKSPACE",
	hl.dsp.exec_cmd("hyprland-window-single-square-aspect-toggle"),
	{ description = "Toggle single-window square aspect" }
)

-- Notifications
hl.bind("SUPER + COMMA", hl.dsp.exec_cmd("makoctl dismiss"), { description = "Dismiss last notification" })
hl.bind(
	"SUPER + SHIFT + COMMA",
	hl.dsp.exec_cmd("makoctl dismiss --all"),
	{ description = "Dismiss all notifications" }
)
hl.bind(
	"SUPER + CTRL + COMMA",
	hl.dsp.exec_cmd("toggle-notification-silencing"),
	{ description = "Toggle silencing notifications" }
)
hl.bind("SUPER + ALT + COMMA", hl.dsp.exec_cmd("makoctl invoke"), { description = "Invoke last notification" })
hl.bind(
	"SUPER + ALT + SHIFT + COMMA",
	hl.dsp.exec_cmd("makoctl restore"),
	{ description = "Restore last notification" }
)

-- Toggles
hl.bind("SUPER + CTRL + I", hl.dsp.exec_cmd("toggle-idle"), { description = "Toggle locking on idle" })
hl.bind("SUPER + CTRL + N", hl.dsp.exec_cmd("toggle-nightlight"), { description = "Toggle nightlight" })

-- Control Apple Display brightness
hl.bind(
	"CTRL + F1",
	hl.dsp.exec_cmd("brightness-display-apple -5000"),
	{ description = "Apple Display brightness down" }
)
hl.bind("CTRL + F2", hl.dsp.exec_cmd("brightness-display-apple +5000"), { description = "Apple Display brightness up" })
hl.bind(
	"SHIFT + CTRL + F2",
	hl.dsp.exec_cmd("brightness-display-apple +60000"),
	{ description = "Apple Display full brightness" }
)

-- Captures
hl.bind("PRINT", hl.dsp.exec_cmd("screenshot"), { description = "Screenshot" })
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd("menu screenrecord"), { description = "Screenrecording" })
hl.bind("SUPER + ALT + PRINT", hl.dsp.exec_cmd("pkill hyprpicker || hyprpicker -a"), { description = "Color picker" })

-- File sharing
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("menu share"), { description = "Share" })

-- Waybar-less information
hl.bind(
	"SUPER + ALT + CTRL + T",
	hl.dsp.exec_cmd('notify-send "    $(date +"%A %H:%M  —  %d %B W%V %Y")"'),
	{ description = "Show time" }
)

-- Control panels
hl.bind("SUPER + CTRL + A", hl.dsp.exec_cmd("launch-audio"), { description = "Audio controls" })
hl.bind("SUPER + CTRL + T", hl.dsp.exec_cmd("launch-tui btop"), { description = "Activity" })

-- Zoom
hl.bind(
	"SUPER + CTRL + Z",
	hl.dsp.exec_cmd(
		"hyprland-eval 'hl.config({ cursor = { zoom_factor = hl.get_config(\"cursor.zoom_factor\") + 1 } })'"
	),
	{ description = "Zoom in" }
)
hl.bind(
	"SUPER + ALT + CTRL + Z",
	hl.dsp.exec_cmd("hyprland-eval 'hl.config({ cursor = { zoom_factor = 1 } })'"),
	{ description = "Reset zoom" }
)

-- Lock system
hl.bind("SUPER + CTRL + ESCAPE", hl.dsp.exec_cmd("lock-screen"), { description = "Lock system" })
