-- Float Steam
hl.window_rule({ name = "steam-1", match = { class = "steam" }, float = true })
hl.window_rule({ name = "steam-2", match = { class = "steam", title = "Steam" }, center = true })
hl.window_rule({ name = "steam-3", match = { class = "steam.*" }, tag = "-default-opacity" })
hl.window_rule({ name = "steam-4", match = { class = "steam.*" }, opacity = "1 1" })
hl.window_rule({ name = "steam-5", match = { class = "steam", title = "Steam" }, size = "1100 700" })
hl.window_rule({ name = "steam-6", match = { class = "steam", title = "Friends List" }, size = "460 800" })
hl.window_rule({ name = "steam-7", match = { class = "steam" }, idle_inhibit = "fullscreen" })
