local activeBorderColor = "rgb(7aa2f7)"

hl.config({ ["general.col.active_border"] = activeBorderColor })

hl.config({ ["group.col.border_active"] = activeBorderColor })

hl.config({
	general = { col = { inactive_border = "rgba(a9b1d633)" } },
	group = {
		groupbar = {
			text_color = "rgb(a9b1d6)",
			text_color_inactive = "rgba(a9b1d6bb)",
			col = {
				active = "rgba(7aa2f740)",
				inactive = "rgba(a9b1d618)",
			},
		},
	},
})
