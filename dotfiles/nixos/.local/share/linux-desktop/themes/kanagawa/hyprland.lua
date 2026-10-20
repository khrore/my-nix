local activeBorderColor = "rgb(dcd7ba)"

hl.config({ ["general.col.active_border"] = activeBorderColor })

hl.config({ ["group.col.border_active"] = activeBorderColor })

hl.config({
	general = { col = { inactive_border = "rgba(dcd7ba33)" } },
	group = {
		groupbar = {
			text_color = "rgb(dcd7ba)",
			text_color_inactive = "rgba(dcd7babb)",
			col = {
				active = "rgba(7e9cd840)",
				inactive = "rgba(dcd7ba18)",
			},
		},
	},
})
