-- Shared session state for shell helpers. Hyprland recreates Lua state on reload.
-- Keep settings in the configuration; helpers read their effective values here.
desktop = { monitor_rules = {} }

function desktop.dispatch(dispatcher)
	local result = hl.dispatch(dispatcher)
	assert(result and result.ok, result and result.error or "Hyprland dispatch failed")
end

function desktop.capture_gaps()
	desktop.gaps = {
		gaps_in = hl.get_config("general.gaps_in"),
		gaps_out = hl.get_config("general.gaps_out"),
		border_size = hl.get_config("general.border_size"),
	}
	desktop.gaps_disabled = false
end

function desktop.toggle_gaps()
	assert(desktop.gaps, "Configuration has not captured gap settings")
	hl.config({ general = desktop.gaps_disabled and desktop.gaps or { gaps_in = 0, gaps_out = 0, border_size = 0 } })
	desktop.gaps_disabled = not desktop.gaps_disabled
end

function desktop.toggle_aspect()
	local ratio = hl.get_config("layout.single_window_aspect_ratio")
	local square = ratio[1] == 1 and ratio[2] == 1
	hl.config({ layout = { single_window_aspect_ratio = square and { 0, 0 } or { 1, 1 } } })
end

function desktop.toggle_layout()
	local workspace = hl.get_active_workspace()
	assert(workspace, "No active workspace")
	hl.workspace_rule({
		workspace = workspace.id,
		layout = workspace.tiled_layout == "dwindle" and "scrolling" or "dwindle",
	})
end

local function copy(source)
	local target = {}
	for key, value in pairs(source) do
		target[key] = value
	end
	return target
end

-- Register personal monitor rules through this helper so runtime scaling can copy
-- a fallback/description rule without losing its HDR, VRR, mirror or other options.
function desktop.monitor(spec)
	local merged = copy(desktop.monitor_rules[spec.output] or {})
	for key, value in pairs(spec) do
		merged[key] = value
	end
	desktop.monitor_rules[spec.output] = merged
	hl.monitor(spec)
end

function desktop.cycle_scale()
	local monitor = hl.get_active_monitor()
	assert(monitor, "No active monitor")
	local original = desktop.monitor_rules[monitor.name]
	if not original then
		for output, rule in pairs(desktop.monitor_rules) do
			if output:sub(1, 5) == "desc:" and monitor.description:sub(1, #output - 5) == output:sub(6) then
				original = rule
				break
			end
		end
	end
	local spec = copy(original or desktop.monitor_rules[""] or {})
	spec.output = monitor.name
	-- Freeze the actual arrangement rather than recalculating "auto" positions.
	spec.position = string.format("%dx%d", monitor.x, monitor.y)
	spec.transform = monitor.transform
	spec.cm = spec.cm or monitor.cm
	local scales = { [10] = 1.6, [16] = 2, [20] = 3 }
	spec.scale = monitor.scale
	desktop.scale_previous = copy(spec)
	spec.scale = scales[math.floor(monitor.scale * 10 + 0.5)] or 1
	local old_notification = hl.get_config("misc.disable_scale_notification")
	hl.config({ misc = { disable_scale_notification = true } })
	local ok, err = pcall(function()
		hl.monitor(spec)
		hl.exec_scheduled_prop_refresh_immediately()
		desktop.scale_target = spec.scale
		desktop.scale_monitor = monitor.name
	end)
	hl.config({ misc = { disable_scale_notification = old_notification } })
	assert(ok, err)
end

function desktop.pop(width, height, x, y)
	local window = hl.get_active_window()
	if not window then
		return
	end
	local function dispatch(operation, options)
		options.window = window
		desktop.dispatch(operation(options))
	end
	if window.pinned then
		dispatch(hl.dsp.window.pin, { action = "off" })
		dispatch(hl.dsp.window.tag, { tag = "-pop" })
		dispatch(hl.dsp.window.float, { action = "off" })
	else
		dispatch(hl.dsp.window.float, { action = "on" })
		dispatch(hl.dsp.window.resize, { x = width, y = height, relative = false })
		if x and y then
			dispatch(hl.dsp.window.move, { x = x, y = y, relative = false })
		else
			dispatch(hl.dsp.window.center, {})
		end
		dispatch(hl.dsp.window.pin, { action = "on" })
		dispatch(hl.dsp.window.alter_zorder, { mode = "top" })
		dispatch(hl.dsp.window.tag, { tag = "+pop" })
	end
end

function desktop.launch_screensaver(terminal)
	local root = os.getenv("LINUX_SESSION_ROOT") or (os.getenv("HOME") .. "/.local/share/linux-desktop")
	local function quote(value)
		return "'" .. value:gsub("'", "'\\''") .. "'"
	end
	local commands = {
		alacritty = "alacritty --class=local.screensaver --config-file " .. quote(
			root .. "/default/alacritty/screensaver.toml"
		) .. " -e screensaver",
		ghostty = "ghostty --class=local.screensaver --config-file="
			.. quote(root .. "/default/ghostty/screensaver")
			.. " --font-size=18 -e screensaver",
		kitty = "kitty --class=local.screensaver --override font_size=18 --override window_padding_width=0 -e screensaver",
	}
	local command = assert(commands[terminal], "Unsupported screensaver terminal")
	for _, monitor in ipairs(hl.get_monitors()) do
		if not monitor.is_mirror and monitor.active_workspace then
			hl.exec_cmd(
				command,
				{ monitor = monitor.name, workspace = tostring(monitor.active_workspace.id) .. " silent" }
			)
		end
	end
end
