-- Personal autostart. This event runs only at startup, never on a normal reload.
-- Keep Walker's data provider and D-Bus service ready before the launcher opens.
hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm-app -- elephant")
	hl.exec_cmd("uwsm-app -- walker --gapplication-service")
end)
