local activeBorderColor = "rgb(7daea3)"

hl.config({ ["general.col.active_border"] = activeBorderColor })

hl.config({ ["group.col.border_active"] = activeBorderColor })

hl.config({
	general = { col = { inactive_border = "rgba(d4be9833)" } },
	group = {
		groupbar = {
			text_color = "rgb(d4be98)",
			text_color_inactive = "rgba(d4be98bb)",
			col = {
				active = "rgba(7daea340)",
				inactive = "rgba(d4be9818)",
			},
		},
	},
})
