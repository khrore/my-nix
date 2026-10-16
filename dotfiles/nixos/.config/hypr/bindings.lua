-- Application bindings
hl.bind(
	"ALT + Return",
	hl.dsp.exec_cmd('uwsm-app -- xdg-terminal-exec --dir="$(terminal-cwd)"'),
	{ description = "Terminal" }
)
hl.bind(
	"SUPER + ALT + Return",
	hl.dsp.exec_cmd('uwsm-app -- xdg-terminal-exec --dir="$(terminal-cwd)" bash -c "tmux attach || tmux new -s Work"'),
	{ description = "Tmux" }
)
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("launch-browser"), { description = "Browser" })
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window"), { description = "File manager" })
hl.bind(
	"SUPER + ALT + SHIFT + F",
	hl.dsp.exec_cmd('uwsm-app -- nautilus --new-window "$(terminal-cwd)"'),
	{ description = "File manager (cwd)" }
)
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("launch-browser"), { description = "Browser" })
hl.bind("SUPER + SHIFT + ALT + B", hl.dsp.exec_cmd("launch-browser --private"), { description = "Browser (private)" })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("launch-or-focus spotify"), { description = "Music" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("launch-editor"), { description = "Editor" })
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("launch-tui lazydocker"), { description = "Docker" })
hl.bind(
	"SUPER + SHIFT + G",
	hl.dsp.exec_cmd('launch-or-focus ^signal$ "uwsm-app -- signal-desktop"'),
	{ description = "Signal" }
)
hl.bind(
	"SUPER + SHIFT + O",
	hl.dsp.exec_cmd('launch-or-focus ^obsidian$ "uwsm-app -- obsidian -disable-gpu --enable-wayland-ime"'),
	{ description = "Obsidian" }
)
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("uwsm-app -- typora --enable-wayland-ime"), { description = "Typora" })
hl.bind("SUPER + SHIFT + slash", hl.dsp.exec_cmd("uwsm-app -- bitwarden"), { description = "Passwords" })

-- Add extra bindings
hl.bind(
	"SUPER + TAB",
	hl.dsp.exec_cmd("hyprctl switchxkblayout gaming-keyboard next"),
	{ description = "Keyboard layout (gaming keyboard)" }
)

-- Override existing bindings, such as putting the main menu on Super + Space

hl.bind(
	"SUPER + SHIFT + R",
	hl.dsp.exec_cmd("hyprctl switchxkblayout all next"),
	{ description = "Keyboard layout (all keyboards)" }
)
