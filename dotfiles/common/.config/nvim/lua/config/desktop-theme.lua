local M = {}
local selected
local timer
local root = (vim.env.LINUX_SESSION_ROOT or (vim.fn.expand("~") .. "/.local/share/linux-desktop")) .. "/current/"

local function apply()
	local name_file = io.open(root .. "theme.name", "r")
	local name = name_file and name_file:read("*l") or "gruvbox"
	if name_file then
		name_file:close()
	end
	if selected == name then
		return
	end

	-- Theme specifications already define the matching plugin and colorscheme.
	local ok, specs = pcall(dofile, root .. "theme/neovim.lua")
	local scheme = "gruvbox"
	if ok then
		for _, spec in ipairs(specs) do
			if spec[1] == "LazyVim/LazyVim" then
				scheme = spec.opts.colorscheme
			else
				require("lazy").load({ plugins = { spec.name or spec[1]:match("/([^/]+)$") } })
			end
		end
	else
		require("lazy").load({ plugins = { "gruvbox.nvim" } })
	end
	vim.o.background = "dark"
	local loaded, err = pcall(vim.cmd.colorscheme, scheme)
	if loaded then
		selected = name
	else
		vim.notify("Desktop theme: " .. tostring(err), vim.log.levels.WARN)
	end
end

function M.setup()
	apply()
	if vim.fn.has("linux") ~= 1 or timer then
		return
	end
	-- Poll the name rather than a file inode: theme-set replaces the theme directory.
	timer = assert(vim.uv.new_timer())
	timer:start(1000, 1000, vim.schedule_wrap(apply))
	vim.api.nvim_create_autocmd("VimLeavePre", {
		once = true,
		callback = function()
			timer:stop()
			timer:close()
		end,
	})
end

return M
