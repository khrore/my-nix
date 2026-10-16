-- Browser types
hl.window_rule({
	name = "browser-1",
	match = { class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)" },
	tag = "+chromium-based-browser",
})
hl.window_rule({ name = "browser-2", match = { class = "([fF]irefox|zen|librewolf)" }, tag = "+firefox-based-browser" })
hl.window_rule({ name = "browser-3", match = { tag = "chromium-based-browser" }, tag = "-default-opacity" })
hl.window_rule({ name = "browser-4", match = { tag = "firefox-based-browser" }, tag = "-default-opacity" })

-- Only a subtle opacity change
hl.window_rule({ name = "browser-5", match = { tag = "chromium-based-browser" }, opacity = "1.0 0.97" })
hl.window_rule({ name = "browser-6", match = { tag = "firefox-based-browser" }, opacity = "1.0 0.97" })
