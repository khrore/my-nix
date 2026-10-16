-- Close windows
hl.bind("ALT + W", hl.dsp.window.close(), { description = "Close window" })
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("hyprland-window-close-all"), { description = "Close all windows" })

-- Control tiling
hl.bind("ALT + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle window floating/tiling" })
hl.bind("ALT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Full screen" })
hl.bind("ALT + O", hl.dsp.exec_cmd("hyprland-window-pop"), { description = "Pop window out (float & pin)" })

-- Move focus with ALT + vi motion
hl.bind("ALT + H", hl.dsp.focus({ direction = "left" }), { description = "Move window focus left" })
hl.bind("ALT + L", hl.dsp.focus({ direction = "right" }), { description = "Move window focus right" })
hl.bind("ALT + K", hl.dsp.focus({ direction = "up" }), { description = "Move window focus up" })
hl.bind("ALT + J", hl.dsp.focus({ direction = "down" }), { description = "Move window focus down" })

-- Switch workspaces with ALT + [1-9; 0]
hl.bind("ALT + code:10", hl.dsp.focus({ workspace = 1 }), { description = "Switch to workspace 1" })
hl.bind("ALT + code:11", hl.dsp.focus({ workspace = 2 }), { description = "Switch to workspace 2" })
hl.bind("ALT + code:12", hl.dsp.focus({ workspace = 3 }), { description = "Switch to workspace 3" })
hl.bind("ALT + code:13", hl.dsp.focus({ workspace = 4 }), { description = "Switch to workspace 4" })
hl.bind("ALT + code:14", hl.dsp.focus({ workspace = 5 }), { description = "Switch to workspace 5" })
hl.bind("ALT + code:15", hl.dsp.focus({ workspace = 6 }), { description = "Switch to workspace 6" })
hl.bind("ALT + code:16", hl.dsp.focus({ workspace = 7 }), { description = "Switch to workspace 7" })
hl.bind("ALT + code:17", hl.dsp.focus({ workspace = 8 }), { description = "Switch to workspace 8" })
hl.bind("ALT + code:18", hl.dsp.focus({ workspace = 9 }), { description = "Switch to workspace 9" })
hl.bind("ALT + code:19", hl.dsp.focus({ workspace = 10 }), { description = "Switch to workspace 10" })

-- Move active window to a workspace with ALT + SHIFT + [1-9; 0]
hl.bind("ALT + SHIFT + code:10", hl.dsp.window.move({ workspace = 1 }), { description = "Move window to workspace 1" })
hl.bind("ALT + SHIFT + code:11", hl.dsp.window.move({ workspace = 2 }), { description = "Move window to workspace 2" })
hl.bind("ALT + SHIFT + code:12", hl.dsp.window.move({ workspace = 3 }), { description = "Move window to workspace 3" })
hl.bind("ALT + SHIFT + code:13", hl.dsp.window.move({ workspace = 4 }), { description = "Move window to workspace 4" })
hl.bind("ALT + SHIFT + code:14", hl.dsp.window.move({ workspace = 5 }), { description = "Move window to workspace 5" })
hl.bind("ALT + SHIFT + code:15", hl.dsp.window.move({ workspace = 6 }), { description = "Move window to workspace 6" })
hl.bind("ALT + SHIFT + code:16", hl.dsp.window.move({ workspace = 7 }), { description = "Move window to workspace 7" })
hl.bind("ALT + SHIFT + code:17", hl.dsp.window.move({ workspace = 8 }), { description = "Move window to workspace 8" })
hl.bind("ALT + SHIFT + code:18", hl.dsp.window.move({ workspace = 9 }), { description = "Move window to workspace 9" })
hl.bind(
	"ALT + SHIFT + code:19",
	hl.dsp.window.move({ workspace = 10 }),
	{ description = "Move window to workspace 10" }
)

-- Move active window silently to a workspace with ALT + SHIFT + ALT + [1-9; 0]
hl.bind(
	"SUPER + ALT + SHIFT + code:10",
	hl.dsp.window.move({ workspace = 1, follow = false }),
	{ description = "Move window silently to workspace 1" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:11",
	hl.dsp.window.move({ workspace = 2, follow = false }),
	{ description = "Move window silently to workspace 2" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:12",
	hl.dsp.window.move({ workspace = 3, follow = false }),
	{ description = "Move window silently to workspace 3" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:13",
	hl.dsp.window.move({ workspace = 4, follow = false }),
	{ description = "Move window silently to workspace 4" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:14",
	hl.dsp.window.move({ workspace = 5, follow = false }),
	{ description = "Move window silently to workspace 5" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:15",
	hl.dsp.window.move({ workspace = 6, follow = false }),
	{ description = "Move window silently to workspace 6" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:16",
	hl.dsp.window.move({ workspace = 7, follow = false }),
	{ description = "Move window silently to workspace 7" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:17",
	hl.dsp.window.move({ workspace = 8, follow = false }),
	{ description = "Move window silently to workspace 8" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:18",
	hl.dsp.window.move({ workspace = 9, follow = false }),
	{ description = "Move window silently to workspace 9" }
)
hl.bind(
	"SUPER + ALT + SHIFT + code:19",
	hl.dsp.window.move({ workspace = 10, follow = false }),
	{ description = "Move window silently to workspace 10" }
)

-- Swap active window with the one next to it with SUPER + SHIFT + arrow keys
hl.bind("ALT + SHIFT + H", hl.dsp.window.swap({ direction = "left" }), { description = "Swap window to the left" })
hl.bind("ALT + SHIFT + L", hl.dsp.window.swap({ direction = "right" }), { description = "Swap window to the right" })
hl.bind("ALT + SHIFT + K", hl.dsp.window.swap({ direction = "up" }), { description = "Swap window up" })
hl.bind("ALT + SHIFT + J", hl.dsp.window.swap({ direction = "down" }), { description = "Swap window down" })

-- Resize active window
hl.bind(
	"ALT + code:20",
	hl.dsp.window.resize({ x = -100, y = 0, relative = true }),
	{ description = "Expand window left" }
)
hl.bind(
	"ALT + code:21",
	hl.dsp.window.resize({ x = 100, y = 0, relative = true }),
	{ description = "Shrink window left" }
)
hl.bind(
	"ALT + SHIFT + code:20",
	hl.dsp.window.resize({ x = 0, y = -100, relative = true }),
	{ description = "Shrink window up" }
)
hl.bind(
	"ALT + SHIFT + code:21",
	hl.dsp.window.resize({ x = 0, y = 100, relative = true }),
	{ description = "Expand window down" }
)

-- Toggle groups
hl.bind("ALT + G", hl.dsp.group.toggle(), { description = "Toggle window grouping" })
hl.bind(
	"SUPER + ALT + G",
	hl.dsp.window.move({ out_of_group = true }),
	{ description = "Move active window out of group" }
)

-- Join groups
hl.bind(
	"SUPER + ALT + H",
	hl.dsp.window.move({ into_group = "left" }),
	{ description = "Move window to group on left" }
)
hl.bind(
	"SUPER + ALT + L",
	hl.dsp.window.move({ into_group = "right" }),
	{ description = "Move window to group on right" }
)
hl.bind("SUPER + ALT + K", hl.dsp.window.move({ into_group = "up" }), { description = "Move window to group on top" })
hl.bind(
	"SUPER + ALT + J",
	hl.dsp.window.move({ into_group = "down" }),
	{ description = "Move window to group on bottom" }
)

-- Navigate a single set of grouped windows
hl.bind("SUPER + ALT + TAB", hl.dsp.group.next(), { description = "Next window in group" })
hl.bind("SUPER + ALT + SHIFT + TAB", hl.dsp.group.prev(), { description = "Previous window in group" })

-- Window navigation for grouped windows
hl.bind("ALT + CTRL + H", hl.dsp.group.prev(), { description = "Move grouped window focus left" })
hl.bind("SUPER + ALT + CTRL + L", hl.dsp.group.next(), { description = "Move grouped window focus right" })

-- Scroll through a set of grouped windows with SUPER + ALT + scroll
hl.bind("SUPER + ALT + mouse_down", hl.dsp.group.next(), { description = "Next window in group" })
hl.bind("SUPER + ALT + mouse_up", hl.dsp.group.prev(), { description = "Previous window in group" })

-- Activate window in a group by number
hl.bind("SUPER + ALT + code:10", hl.dsp.group.active({ index = 1 }), { description = "Switch to group window 1" })
hl.bind("SUPER + ALT + code:11", hl.dsp.group.active({ index = 2 }), { description = "Switch to group window 2" })
hl.bind("SUPER + ALT + code:12", hl.dsp.group.active({ index = 3 }), { description = "Switch to group window 3" })
hl.bind("SUPER + ALT + code:13", hl.dsp.group.active({ index = 4 }), { description = "Switch to group window 4" })
hl.bind("SUPER + ALT + code:14", hl.dsp.group.active({ index = 5 }), { description = "Switch to group window 5" })

-- Cycle monitor scaling
hl.bind("ALT + slash", hl.dsp.exec_cmd("hyprland-monitor-scaling-cycle"), { description = "Cycle monitor scaling" })
