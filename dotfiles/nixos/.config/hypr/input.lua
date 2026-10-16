-- Personal input settings. Caps Lock switches between English and Russian.
hl.config({
	input = {
		kb_layout = "us,ru",
		kb_options = "grp:caps_toggle",
		repeat_rate = 40,
		repeat_delay = 400,
		numlock_by_default = true,
		sensitivity = 0,
		accel_profile = "flat",
		touchpad = {
			scroll_factor = 0.4,
		},
	},
})

hl.window_rule({ name = "input-1", match = { class = "(Alacritty|kitty)" }, scroll_touchpad = 1.5 })
hl.window_rule({ name = "input-2", match = { class = "com.mitchellh.ghostty" }, scroll_touchpad = 0.2 })
