[mgr]
cwd = { fg = "{{ color6 }}" }

find_keyword  = { fg = "{{ color3 }}", italic = true }
find_position = { fg = "{{ color5 }}", bg = "reset", italic = true }

marker_copied   = { fg = "{{ color2 }}", bg = "{{ color2 }}" }
marker_cut      = { fg = "{{ color1 }}", bg = "{{ color1 }}" }
marker_marked   = { fg = "{{ color6 }}", bg = "{{ color6 }}" }
marker_selected = { fg = "{{ accent }}", bg = "{{ accent }}" }

count_copied   = { fg = "{{ background }}", bg = "{{ color2 }}" }
count_cut      = { fg = "{{ background }}", bg = "{{ color1 }}" }
count_selected = { fg = "{{ background }}", bg = "{{ accent }}" }

border_symbol = "│"
border_style  = { fg = "{{ color8 }}" }


[tabs]
active   = { fg = "{{ background }}", bg = "{{ foreground }}", bold = true }
inactive = { fg = "{{ foreground }}", bg = "{{ color0 }}" }

[mode]
normal_main = { fg = "{{ background }}", bg = "{{ accent }}", bold = true }
normal_alt  = { fg = "{{ accent }}", bg = "{{ color0 }}"}

select_main = { fg = "{{ background }}", bg = "{{ color2 }}", bold = true }
select_alt  = { fg = "{{ color2 }}", bg = "{{ color0 }}"}

unset_main  = { fg = "{{ background }}", bg = "{{ color1 }}", bold = true }
unset_alt   = { fg = "{{ color1 }}", bg = "{{ color0 }}"}

[indicator]
parent = { fg = "{{ background }}", bg = "{{ accent }}" }
current = { fg = "{{ background }}", bg = "{{ accent }}" }
preview = { fg = "{{ background }}", bg = "{{ foreground }}" }

[status]
sep_left = { open = "", close = "" }
sep_right = { open = "", close = "" }

progress_label  = { fg = "{{ foreground }}", bold = true }
progress_normal = { fg = "{{ accent }}", bg = "{{ color0 }}" }
progress_error  = { fg = "{{ color1 }}", bg = "{{ color0 }}" }

perm_type  = { fg = "{{ accent }}" }
perm_read  = { fg = "{{ color3 }}" }
perm_write = { fg = "{{ color1 }}" }
perm_exec  = { fg = "{{ color2 }}" }
perm_sep   = { fg = "{{ color8 }}" }

[input]
border   = { fg = "{{ accent }}" }
title    = {}
value    = {}
selected = { reversed = true }

[pick]
border   = { fg = "{{ accent }}" }
active   = { fg = "{{ color5 }}" }
inactive = {}

[confirm]
border     = { fg = "{{ accent }}" }
title      = { fg = "{{ accent }}" }
body       = {}
list       = {}
btn_yes    = { reversed = true }
btn_no     = {}

[cmp]
border = { fg = "{{ accent }}" }

[tasks]
border  = { fg = "{{ accent }}" }
title   = {}
hovered = { underline = true }

[which]
mask            = { bg = "{{ color0 }}" }
cand            = { fg = "{{ color6 }}" }
rest            = { fg = "{{ color7 }}" }
desc            = { fg = "{{ color5 }}" }
separator       = "  "
separator_style = { fg = "{{ color8 }}" }

[help]
border = { fg = "{{ accent }}" }
chord = { fg = "{{ color6 }}" }
action = { fg = "{{ color5 }}" }
hovered = { bg = "{{ color8 }}", bold = true }

[notify]
title_info  = { fg = "{{ color6 }}" }
title_warn  = { fg = "{{ color3 }}" }
title_error = { fg = "{{ color1 }}" }

[filetype]
rules = [
	# Media
	{ mime = "**/image/*", fg = "{{ color6 }}" },
	{ mime = "**/{audio,video}/*", fg = "{{ color3 }}" },

	# Archives
	{ mime = "**/application/*zip", fg = "{{ color5 }}" },
	{ mime = "**/application/x-{tar,bzip*,7z-compressed,xz,rar}", fg = "{{ color5 }}" },

	# Documents
	{ mime = "**/application/{pdf,doc,rtf}", fg = "{{ color2 }}" },

	# Fallback
	{ url = "*", fg = "{{ foreground }}" },
	{ url = "*/", fg = "{{ accent }}" }
]

[spot]
border = { fg = "{{ accent }}" }
title  = { fg = "{{ accent }}" }
tbl_cell = { fg = "{{ accent }}", reversed = true }
tbl_col = { bold = true }

