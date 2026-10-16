-- Webcam overlay for screen recording
hl.window_rule({ name = "webcam-overlay-1", match = { title = "WebcamOverlay" }, float = true })
hl.window_rule({ name = "webcam-overlay-2", match = { title = "WebcamOverlay" }, pin = true })
hl.window_rule({ name = "webcam-overlay-3", match = { title = "WebcamOverlay" }, no_initial_focus = true })
hl.window_rule({ name = "webcam-overlay-4", match = { title = "WebcamOverlay" }, no_dim = true })
hl.window_rule({
	name = "webcam-overlay-5",
	match = { title = "WebcamOverlay" },
	move = "(monitor_w-window_w-40) (monitor_h-window_h-40)",
})
