local activeBorderColor = "rgb(f2fcff)"
local activeShadowColor = "rgb(6fb8e3)"
local inactiveBorderColor = "rgba(30486099)"
local inactiveShadowColor = "rgba(30486077)"

hl.config({ ["general.col.active_border"] = activeBorderColor })
hl.config({ ["general.col.inactive_border"] = inactiveBorderColor })
hl.config({ ["general.gaps_in"] = 8 })
hl.config({ ["general.gaps_out"] = 16 })

hl.config({ ["group.col.border_active"] = activeBorderColor })
hl.config({ ["group.col.border_inactive"] = inactiveBorderColor })

hl.config({ ["decoration.shadow.enabled"] = true })
hl.config({ ["decoration.shadow.range"] = 16 })
hl.config({ ["decoration.shadow.render_power"] = 4 })
hl.config({ ["decoration.shadow.color"] = activeShadowColor })
hl.config({ ["decoration.shadow.color_inactive"] = inactiveShadowColor })
