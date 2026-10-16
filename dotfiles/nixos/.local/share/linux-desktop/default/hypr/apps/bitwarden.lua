hl.window_rule({ name = "bitwarden-1", match = { class = "^(Bitwarden)$" }, no_screen_share = true })
hl.window_rule({ name = "bitwarden-2", match = { class = "^(Bitwarden)$" }, tag = "+floating-window" })

-- Bitwarden Chrome Extension
hl.window_rule({
	name = "bitwarden-3",
	match = { class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default" },
	no_screen_share = true,
})
hl.window_rule({
	name = "bitwarden-4",
	match = { class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default" },
	tag = "+floating-window",
})
