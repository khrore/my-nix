-- Regression tests for decisions that config parsing alone cannot check.
local root = assert(arg[1])
local config = {
	["general.gaps_in"] = { top = 8, right = 8, bottom = 8, left = 8 },
	["general.gaps_out"] = { top = 16, right = 16, bottom = 16, left = 16 },
	["general.border_size"] = 2,
	["layout.single_window_aspect_ratio"] = { 0, 0 },
	["misc.disable_scale_notification"] = false,
}
local active, monitor, fail
local calls = {}
local dispatcher = setmetatable({}, {
	__index = function(_, key)
		return function(options)
			return { operation = key, options = options }
		end
	end,
})
hl = {
	dsp = { window = dispatcher },
	get_config = function(key)
		return config[key]
	end,
	get_active_window = function()
		return active
	end,
	get_active_monitor = function()
		return monitor
	end,
	get_active_workspace = function()
		return { id = 3, tiled_layout = "dwindle" }
	end,
	config = function(options)
		for category, fields in pairs(options) do
			for key, value in pairs(fields) do
				config[category .. "." .. key] = value
			end
		end
	end,
	dispatch = function(operation)
		calls[#calls + 1] = operation
		return fail and { ok = false, error = "rejected" } or { ok = true }
	end,
	monitor = function(spec)
		calls[#calls + 1] = spec
		if fail then
			error("rejected")
		end
		if monitor then
			monitor.scale = spec.scale
		end
	end,
	workspace_rule = function(rule)
		calls[#calls + 1] = rule
	end,
	exec_scheduled_prop_refresh_immediately = function() end,
}
dofile(root .. "/dotfiles/nixos/.local/share/linux-desktop/default/hypr/runtime.lua")
desktop.capture_gaps()
desktop.toggle_gaps()
assert(config["general.gaps_out"] == 0)
desktop.toggle_gaps()
assert(config["general.gaps_out"].top == 16 and config["general.gaps_in"].left == 8)
-- Personal/asymmetric gaps must survive too.
config["general.gaps_out"] = { top = 1, right = 2, bottom = 3, left = 4 }
desktop.capture_gaps()
desktop.toggle_gaps()
desktop.toggle_gaps()
assert(config["general.gaps_out"].left == 4)
desktop.toggle_aspect()
assert(config["layout.single_window_aspect_ratio"][1] == 1)
desktop.toggle_aspect()
assert(config["layout.single_window_aspect_ratio"][1] == 0)
desktop.toggle_layout()
assert(calls[#calls].layout == "scrolling" and calls[#calls].workspace == 3)
local count = #calls
desktop.pop(900, 600)
assert(#calls == count)
active = { pinned = false }
desktop.pop(900, 600, -20, 30)
for i = count + 1, #calls do
	assert(calls[i].options.window == active)
end
assert(calls[count + 1].operation == "float" and calls[count + 1].options.action == "on")
assert(calls[count + 2].options.relative == false)
assert(calls[count + 3].options.x == -20)
active.pinned = true
desktop.pop(900, 600)
assert(calls[#calls].operation == "float" and calls[#calls].options.action == "off")
fail = true
assert(not pcall(desktop.pop, 900, 600))
fail = false
monitor = { name = "test", description = "test display", x = 100, y = -30, transform = 1, cm = "srgb", scale = 1 }
desktop.monitor({ output = "", scale = 1, bitdepth = 10, vrr = 1, sdrbrightness = 0.8 })
desktop.cycle_scale()
local rule = calls[#calls]
assert(rule.scale == 1.6 and rule.position == "100x-30" and rule.transform == 1)
assert(rule.bitdepth == 10 and rule.vrr == 1 and rule.sdrbrightness == 0.8)
assert(config["misc.disable_scale_notification"] == false)
config["misc.disable_scale_notification"] = true
fail = true
assert(not pcall(desktop.cycle_scale))
assert(config["misc.disable_scale_notification"] == true)
print("runtime regressions: passed")

local launched = {}
hl.get_monitors = function()
	return {
		{ name = "DP-1", active_workspace = { id = 1 } },
		{ name = "DP-2", active_workspace = { id = 2 } },
		{ name = "mirror", is_mirror = true, active_workspace = { id = 1 } },
	}
end
hl.exec_cmd = function(command, rules)
	launched[#launched + 1] = { command = command, rules = rules }
end
desktop.launch_screensaver("alacritty")
assert(#launched == 2)
assert(launched[1].rules.monitor == "DP-1" and launched[1].rules.workspace == "1 silent")
assert(launched[2].rules.monitor == "DP-2" and launched[2].rules.workspace == "2 silent")
assert(not pcall(desktop.launch_screensaver, "unknown"))
