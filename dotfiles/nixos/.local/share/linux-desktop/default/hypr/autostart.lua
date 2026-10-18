-- Polkit is already started by UWSM/XDG-autostart.
-- UWSM owns propagation of the session environment to D-Bus and systemd.
hl.on("hyprland.start", function()
	for _, command in ipairs({
		"theme-set-browser",
		"theme-set-zed",
		"theme-set-zellij",
		"theme-set-codex",
		"theme-set-throne",
		"uwsm-app -- hypridle",
		"uwsm-app -- mako",
		"uwsm-app -- waybar",
		"uwsm-app -- fcitx5 --disable notificationitem",
		[[uwsm-app -- swaybg -i "${LINUX_SESSION_ROOT:-$HOME/.local/share/linux-desktop}/current/background" -m fill]],
		"uwsm-app -- swayosd-server",
	}) do
		hl.exec_cmd(command)
	end
end)
