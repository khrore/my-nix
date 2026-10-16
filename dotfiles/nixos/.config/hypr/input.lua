-- Personal input settings. SUPER+TAB changes the gaming keyboard layout; SUPER+SHIFT+R changes all.
hl.config({
	input = {
		kb_layout = "us,ru",
		kb_options = "compose:caps",
		repeat_rate = 40,
		repeat_delay = 200,
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
