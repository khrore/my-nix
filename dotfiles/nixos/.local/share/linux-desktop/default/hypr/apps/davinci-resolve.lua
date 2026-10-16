-- Focus floating DaVinci Resolve dialog windows
hl.window_rule({ name = "davinci-resolve-1", match = { class = ".*[Rr]esolve.*", float = true }, stay_focused = true })
