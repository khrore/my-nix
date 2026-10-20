return {
	{ "ellisonleao/gruvbox.nvim", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "neanias/everforest-nvim", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "EdenEast/nightfox.nvim", lazy = true },
	{ "folke/tokyonight.nvim", lazy = true },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				require("config.desktop-theme").setup()
			end,
		},
	},
}
