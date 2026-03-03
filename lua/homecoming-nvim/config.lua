--- @type homecoming-nvim.Opts
local default_config = {
	auto_start = true,

	header_centered = false,
	header_hl_group = "Title",
	header_mb = 0,
	header = "Welcome",

	item_gap = 0,
	item_hl_group = "Comment",
	item_selected_hl_group = "Normal",
	item_indent = 2,
	item_prefix_char = "",

	section_anchor = "header",
	section_gap = 1,
	section_hl_group = "Delimiter",
	sections = {
		{
			title = "Actions",
			items = {
				{
					label = "New file",
					action = function()
						vim.cmd("enew")
					end,
				},
				{
					label = "Quit",
					action = function()
						vim.cmd("qa")
					end,
				},
			},
		},
		{
			title = "Resources",
			items = {
				{
					label = "Open config",
					action = function()
						vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
					end,
				},
			},
		},
	},

	footer_anchor = "self",
	footer_hl_group = "ErrorMsg",
	footer_mt = 1,
	footer_mb = 0,
	footer = function()
		return {
			"Have a productive session",
			"Neovim version: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
		}
	end,
}

local M = {}

--- @type homecoming-nvim.Opts
M.opts = default_config

function M.set_opts(user_opts)
	M.opts = vim.tbl_deep_extend("force", {}, default_config, user_opts or {})
end

return M
