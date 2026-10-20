-- Application bindings
hl.bind(
	"SUPER + Return",
	hl.dsp.exec_cmd('uwsm-app -- xdg-terminal-exec --dir="$(terminal-cwd)"'),
	{ description = "Terminal" }
)
hl.bind(
	"SUPER + ALT + Return",
	hl.dsp.exec_cmd('uwsm-app -- xdg-terminal-exec --dir="$(terminal-cwd)" zellij attach --create Work'),
	{ description = "Zellij" }
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
