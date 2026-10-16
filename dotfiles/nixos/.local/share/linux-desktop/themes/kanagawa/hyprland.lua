local activeBorderColor = "rgb(dcd7ba)"

hl.config({ ["general.col.active_border"] = activeBorderColor })

hl.config({ ["group.col.border_active"] = activeBorderColor })

-- Kanagawa backdrop is too strong for detault opacity
hl.window_rule({ name = "theme-kanagawa-opacity", match = { tag = "terminal" }, opacity = "0.98 0.95" })
