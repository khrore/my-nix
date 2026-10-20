-- Hyprland 0.56.2. Environment belongs to UWSM; these files only configure Hyprland.
-- require() is Hyprland's protected, reload-aware loader.
local root = os.getenv("DESKTOP_ROOT")
	or os.getenv("LINUX_SESSION_ROOT")
	or (os.getenv("HOME") .. "/.local/share/desktop")
local config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
require(root .. "/default/hypr/runtime.lua")

require(root .. "/default/hypr/envs.lua")
require(root .. "/default/hypr/looknfeel.lua")
require(root .. "/default/hypr/input.lua")
require(root .. "/default/hypr/windows.lua") -- includes ordered application rules
require(root .. "/default/hypr/bindings/media.lua")
require(root .. "/default/hypr/bindings/clipboard.lua")
require(root .. "/default/hypr/bindings/tiling.lua")
require(root .. "/default/hypr/bindings/utilities.lua")
require(root .. "/default/hypr/autostart.lua")
require(root .. "/current/theme/hyprland.lua")

-- Personal settings win over defaults and the selected theme.
for _, module in ipairs({ "monitors", "input", "bindings", "looknfeel", "autostart" }) do
	require(config .. "/hypr/" .. module .. ".lua")
end
-- Capture final themed/personal values for the gap toggle. Reload resets this state.
desktop.capture_gaps()
