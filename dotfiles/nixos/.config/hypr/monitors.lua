-- Edit monitor rules here. desktop.monitor preserves their options when cycling scale.
-- Inspect available outputs with: hyprctl monitors
-- Toolkit scaling belongs in ~/.config/uwsm/env and takes effect at the next login.
desktop.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
-- Example rotated output:
-- desktop.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
