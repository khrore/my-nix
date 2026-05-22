return {
	-- configuring lsp
	"neovim/nvim-lspconfig",
	dependencies = nil,
	opts = {
		servers = {
			-- lua is already configured
			fish_lsp = {}, -- fish
			bashls = {}, -- bash
			hyprls = {}, -- hyprlang
		},
	},
}
