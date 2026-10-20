local activeBorderColor = "rgb({{ accent_strip }})"

hl.config({ ["general.col.active_border"] = activeBorderColor })

hl.config({ ["group.col.border_active"] = activeBorderColor })

hl.config({
	general = { col = { inactive_border = "rgba({{ foreground_strip }}33)" } },
	group = {
		groupbar = {
			text_color = "rgb({{ foreground_strip }})",
			text_color_inactive = "rgba({{ foreground_strip }}bb)",
			col = {
				active = "rgba({{ accent_strip }}40)",
				inactive = "rgba({{ foreground_strip }}18)",
			},
		},
	},
})
