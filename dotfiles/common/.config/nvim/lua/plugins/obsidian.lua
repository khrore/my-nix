return {
	"obsidian-nvim/obsidian.nvim",
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>oc",
			"<cmd>Obsidian toggle_checkbox<cr>",
			desc = "Toggle checkbox",
			mode = { "n" },
		},
		{
			"<leader>of",
			"<cmd>Obsidian follow_link<cr>",
			desc = "Follow link",
			mode = { "n" },
		},
		{
			"<leader>ol",
			"<cmd>Obsidian link<cr>",
			desc = "Link",
			mode = { "v" },
		},
		{
			"<leader>on",
			"<cmd>Obsidian new_link<cr>",
			desc = "New link",
			mode = { "v" },
		},
		{
			"<leader>or",
			"<cmd>Obsidian backlinks",
			desc = "References to the current buffer",
		},
	},
	opts = {
		-- A list of workspace names, paths, and configuration overrides.
		-- If you use the Obsidian app, the 'path' of a workspace should generally be
		-- your vault root (where the `.obsidian` folder is located).
		-- When obsidian.nvim is loaded by your plugin manager, it will automatically set
		-- the workspace to the first workspace in the list whose `path` is a parent of the
		-- current markdown file being edited.
		legacy_commands = false,

		workspaces = {
			{
				name = "notes",
				path = "/home/khrore/notes",
			},
		},

		-- Alternatively - and for backwards compatibility - you can set 'dir' to a single path instead of
		-- 'workspaces'. For example:
		-- dir = "~/vaults/work",

		-- Optional, set the log level for obsidian.nvim. This is an integer corresponding to one of the log
		-- levels defined by "vim.log.levels.\*".
		log_level = vim.log.levels.INFO,

		daily_notes = {
			-- Optional, if you keep daily notes in a separate directory.
			folder = "notes/dailies",
			-- Optional, if you want to change the date format for the ID of daily notes.
			date_format = "%Y-%m-%d",
			-- Optional, if you want to change the date format of the default alias of daily notes.
			alias_format = "%B %-d, %Y",
			-- Optional, default tags to add to each new daily note created.
			default_tags = { "daily-notes" },
			-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
			template = nil,
			-- Optional, if you want `Obsidian yesterday` to return the last work day or `Obsidian tomorrow` to return the next work day.
			workdays_only = true,
		},

		callbacks = {
			enter_note = function(_, note)
				vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
					buffer = note.bufnr,
					desc = "Toggle checkbox",
				})
			end,
		},

		-- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
		completion = {
			-- Enables completion using nvim_cmp
			nvim_cmp = false,
			-- Enables completion using blink.cmp
			blink = true,
			-- Trigger completion at 2 chars.
			min_chars = 2,
			-- Set to false to disable new note creation in the picker
			create_new = true,
		},

		-- Where to put new notes. Valid options are
		-- _ "current_dir" - put new notes in same directory as the current buffer.
		-- _ "notes_subdir" - put new notes in the default notes subdirectory.
		new_notes_location = "current_dir",

		-- Optional, customize how note IDs are generated given an optional title.
		---@param title string|?
		---@return string
		-- note_id_func = function(title)
		-- 	-- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
		-- 	-- In this case a note with the title 'My new note' will be given an ID that looks
		-- 	-- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'.
		-- 	-- You may have as many periods in the note ID as you'd like—the ".md" will be added automatically
		-- 	local suffix = ""
		-- 	if title ~= nil then
		-- 		-- If title is given, transform it into valid file name.
		-- 		suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
		-- 	else
		-- 		-- If title is nil, just add 4 random uppercase letters to the suffix.
		-- 		for _ = 1, 4 do
		-- 			suffix = suffix .. string.char(math.random(65, 90))
		-- 		end
		-- 	end
		-- 	return ""
		-- end,

		-- Optional, customize how note file names are generated given the ID, target directory, and title.
		---@param spec { id: string, dir: obsidian.Path, title: string|? }
		---@return string|obsidian.Path The full path to the new note.
		note_path_func = function(spec)
			-- This is equivalent to the default behavior.
			local path = spec.dir / tostring(spec.id)
			return path:with_suffix(".md")
		end,

		link = {
			style = "wiki",
		},

		frontmatter = {
			enabled = false,
			func = function(note)
				-- Add the title of the note as an alias.
				if note.title then
					note:add_alias(note.title)
				end

				local out = { id = note.id, aliases = note.aliases, tags = note.tags }

				-- `note.metadata` contains any manually added fields in the frontmatter.
				-- So here we just make sure those fields are kept in the frontmatter.
				if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
					for k, v in pairs(note.metadata) do
						out[k] = v
					end
				end

				return out
			end,
		},

		-- Optional, for templates (see https://github.com/obsidian-nvim/obsidian.nvim/wiki/Using-templates)
		-- templates = {
		-- 	folder = "templates",
		-- 	date_format = "%Y-%m-%d",
		-- 	time_format = "%H:%M",
		-- 	-- A map for custom variables, the key should be the variable and the value a function.
		-- 	-- Functions are called with obsidian.TemplateContext objects as their sole parameter.
		-- 	-- See: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template#substitutions
		-- 	substitutions = {},
		-- },

		---@class obsidian.config.OpenOpts
		---
		---Opens the file with current line number
		---@field use_advanced_uri? boolean
		---
		---Function to do the opening, default to vim.ui.open
		---@field func? fun(uri: string)
		open = {
			use_advanced_uri = false,
			func = vim.ui.open,
		},

		picker = {
			-- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
			name = "fzf-lua",
			-- Optional, configure key mappings for the picker. These are the defaults.
			-- Not all pickers support all mappings.
			note_mappings = {
				-- Create a new note from your query.
				new = "<C-x>",
				-- Insert a link to the selected note.
				insert_link = "<C-l>",
			},
			tag_mappings = {
				-- Add tag(s) to current note.
				tag_note = "<C-x>",
				-- Insert a tag at the current location.
				insert_tag = "<C-l>",
			},
		},

		-- Optional, by default, `:ObsidianBacklinks` parses the header under
		-- the cursor. Setting to `false` will get the backlinks for the current
		-- note instead. Doesn't affect other link behaviour.
		backlinks = {
			parse_headers = true,
		},

		search = {
			sort_by = "modified",
			sort_reversed = true,
			max_lines = 1000,
		},

		-- Optional, determines how certain commands open notes. The valid options are:
		-- 1. "current" (the default) - to always open in the current window
		-- 2. "vsplit" - only open in a vertical split if a vsplit does not exist.
		-- 3. "hsplit" - only open in a horizontal split if a hsplit does not exist.
		-- 4. "vsplit_force" - always open a new vertical split if the file is not in the adjacent vsplit.
		-- 5. "hsplit_force" - always open a new horizontal split if the file is not in the adjacent hsplit.
		open_notes_in = "current",

		-- Optional, define your own callbacks to further customize behavior.
		callbacks = {
			-- Runs at the end of `require("obsidian").setup()`.
			---@param client obsidian.Client
			post_setup = function(client) end,

			-- Runs anytime you enter the buffer for a note.
			---@param client obsidian.Client
			---@param note obsidian.Note
			enter_note = function(client, note) end,

			-- Runs anytime you leave the buffer for a note.
			---@param client obsidian.Client
			---@param note obsidian.Note
			leave_note = function(client, note) end,

			-- Runs right before writing the buffer for a note.
			---@param client obsidian.Client
			---@param note obsidian.Note
			pre_write_note = function(client, note) end,

			-- Runs anytime the workspace is set/changed.
			---@param client obsidian.Client
			---@param workspace obsidian.Workspace
			post_set_workspace = function(client, workspace) end,
		},

		-- Optional, configure additional syntax highlighting / extmarks.
		-- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
		ui = {
			enable = true, -- set to false to disable all additional syntax features
			ignore_conceal_warn = false, -- set to true to disable conceallevel specific warning
			update_debounce = 200, -- update delay after a text change (in milliseconds)
			max_file_length = 5000, -- disable UI features for files with more than this many lines
			-- Use bullet marks for non-checkbox lists.
			bullets = { char = "•", hl_group = "ObsidianBullet" },
			external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			-- Replace the above with this if you don't have a patched font:
			-- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			reference_text = { hl_group = "ObsidianRefText" },
			highlight_text = { hl_group = "ObsidianHighlightText" },
			tags = { hl_group = "ObsidianTag" },
			block_ids = { hl_group = "ObsidianBlockID" },
			hl_groups = {
				-- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
				ObsidianTodo = { bold = true, fg = "#f78c6c" },
				ObsidianDone = { bold = true, fg = "#89ddff" },
				ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
				ObsidianTilde = { bold = true, fg = "#ff5370" },
				ObsidianImportant = { bold = true, fg = "#d73128" },
				ObsidianBullet = { bold = true, fg = "#89ddff" },
				ObsidianRefText = { underline = true, fg = "#c792ea" },
				ObsidianExtLinkIcon = { fg = "#c792ea" },
				ObsidianTag = { italic = true, fg = "#89ddff" },
				ObsidianBlockID = { italic = true, fg = "#89ddff" },
				ObsidianHighlightText = { bg = "#75662e" },
			},
		},

		---@class obsidian.config.AttachmentsOpts
		---
		---Default folder to save images to, relative to the vault root.
		---@field img_folder? string
		---
		---Default name for pasted images
		---@field img_name_func? fun(): string
		---
		---Default text to insert for pasted images
		---@field img_text_func? fun(client: obsidian.Client, path: obsidian.Path): string
		---
		---Whether to confirm the paste or not. Defaults to true.
		---@field confirm_img_paste? boolean
		attachments = {
			folder = "assets/imgs",
			img_text_func = function(path)
				local encoded_path = require("obsidian.util").urlencode(path:vault_relative_path() or tostring(path))
				return string.format("![%s](%s)", path.name, encoded_path)
			end,
			img_name_func = function()
				return string.format("Pasted image %s", os.date("%Y%m%d%H%M%S"))
			end,
			confirm_img_paste = true,
		},

		checkbox = {
			order = { " ", "~", "!", ">", "x" },
		},

		footer = {
			enabled = true,
			format = "{{properties}} properties {{backlinks}} backlinks {{words}} words {{chars}} chars",
		},
	},
}
