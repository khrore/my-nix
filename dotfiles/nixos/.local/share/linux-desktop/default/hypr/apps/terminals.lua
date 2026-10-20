-- Define terminal tag to style them uniformly
hl.window_rule({
	name = "terminals-1",
	match = { class = "(Alacritty|kitty|com.mitchellh.ghostty)" },
	tag = "+terminal",
})
hl.window_rule({ name = "terminals-2", match = { tag = "terminal" }, tag = "-default-opacity" })
hl.window_rule({ name = "terminals-3", match = { tag = "terminal" }, opacity = "1 1" })
