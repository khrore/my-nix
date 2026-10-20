-- Resolve the focused monitor when the key is pressed, not when the config is loaded.
local osdclient = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\""

-- Only display the OSD on the currently focused monitor

-- Laptop multimedia keys for volume and LCD brightness (with OSD)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(osdclient .. " --output-volume raise"),
	{ description = "Volume up", repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(osdclient .. " --output-volume lower"),
	{ description = "Volume down", repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(osdclient .. " --output-volume mute-toggle"),
	{ description = "Mute", repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd(osdclient .. " --input-volume mute-toggle"),
	{ description = "Mute microphone", repeating = true, locked = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightness-display +5%"),
	{ description = "Brightness up", repeating = true, locked = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightness-display 5%-"),
	{ description = "Brightness down", repeating = true, locked = true }
)
hl.bind(
	"XF86KbdBrightnessUp",
	hl.dsp.exec_cmd("brightness-keyboard up"),
	{ description = "Keyboard brightness up", repeating = true, locked = true }
)
hl.bind(
	"XF86KbdBrightnessDown",
	hl.dsp.exec_cmd("brightness-keyboard down"),
	{ description = "Keyboard brightness down", repeating = true, locked = true }
)
hl.bind(
	"XF86KbdLightOnOff",
	hl.dsp.exec_cmd("brightness-keyboard cycle"),
	{ description = "Keyboard backlight cycle", locked = true }
)

-- Precise 1% multimedia adjustments with Super modifier
hl.bind(
	"SUPER + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(osdclient .. " --output-volume +1"),
	{ description = "Volume up precise", repeating = true, locked = true }
)
hl.bind(
	"SUPER + XF86AudioLowerVolume",
	hl.dsp.exec_cmd(osdclient .. " --output-volume -1"),
	{ description = "Volume down precise", repeating = true, locked = true }
)
hl.bind(
	"SUPER + XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightness-display +1%"),
	{ description = "Brightness up precise", repeating = true, locked = true }
)
hl.bind(
	"SUPER + XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightness-display 1%-"),
	{ description = "Brightness down precise", repeating = true, locked = true }
)

-- Requires playerctl
hl.bind(
	"XF86AudioNext",
	hl.dsp.exec_cmd(osdclient .. " --playerctl next"),
	{ description = "Next track", locked = true }
)
hl.bind(
	"XF86AudioPause",
	hl.dsp.exec_cmd(osdclient .. " --playerctl play-pause"),
	{ description = "Pause", locked = true }
)
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd(osdclient .. " --playerctl play-pause"),
	{ description = "Play", locked = true }
)
hl.bind(
	"XF86AudioPrev",
	hl.dsp.exec_cmd(osdclient .. " --playerctl previous"),
	{ description = "Previous track", locked = true }
)

-- Switch audio output with Super + Mute
hl.bind(
	"SUPER + XF86AudioMute",
	hl.dsp.exec_cmd("audio-switch"),
	{ description = "Switch audio output", locked = true }
)
