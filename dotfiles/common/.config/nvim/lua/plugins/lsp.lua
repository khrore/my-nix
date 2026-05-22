local function vue_language_server_plugin_path()
	local executable = vim.fn.exepath("vue-language-server")
	if executable == "" then
		return nil
	end

	local real_executable = vim.uv.fs_realpath(executable) or executable
	local bin_dir = vim.fs.dirname(real_executable)
	local candidates = {
		-- Nix package layout.
		vim.fs.normalize(bin_dir .. "/../lib/language-tools/node_modules/.pnpm/node_modules/@vue/language-server"),
		-- Common npm/global package layouts.
		vim.fs.normalize(bin_dir .. "/../lib/node_modules/@vue/language-server"),
		vim.fs.normalize(bin_dir .. "/../lib/node_modules/vue-language-server/node_modules/@vue/language-server"),
		vim.fs.normalize(bin_dir .. "/../node_modules/@vue/language-server"),
	}

	for _, candidate in ipairs(candidates) do
		if vim.uv.fs_stat(candidate) then
			return candidate
		end
	end

	return nil
end

return {
	-- configuring lsp
	"neovim/nvim-lspconfig",
	dependencies = nil,
	opts = function(_, opts)
		opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
			-- lua is already configured
			fish_lsp = {}, -- fish
			bashls = {}, -- bash
			hyprls = {}, -- hyprlang
			vue_ls = {},
		})

		local vue_plugin_path = vue_language_server_plugin_path()
		if opts.servers.vtsls and vue_plugin_path then
			opts.servers.vtsls.filetypes = opts.servers.vtsls.filetypes
				or {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				}

			if not vim.tbl_contains(opts.servers.vtsls.filetypes, "vue") then
				table.insert(opts.servers.vtsls.filetypes, "vue")
			end

			opts.servers.vtsls.settings = opts.servers.vtsls.settings or {}
			opts.servers.vtsls.settings.vtsls = opts.servers.vtsls.settings.vtsls or {}
			opts.servers.vtsls.settings.vtsls.tsserver = opts.servers.vtsls.settings.vtsls.tsserver or {}
			opts.servers.vtsls.settings.vtsls.tsserver.globalPlugins = {
				{
					name = "@vue/typescript-plugin",
					location = vue_plugin_path,
					languages = { "vue" },
					configNamespace = "typescript",
					enableForWorkspaceTypeScriptVersions = true,
				},
			}
		end
	end,
}
