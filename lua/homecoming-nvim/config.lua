--- @type homecoming-nvim.Opts
local default_config = {
	auto_start = true,

	header_mb = 1,
	header = function()
		return {
			"Welcome 👋",
		}
	end,

	item_gap = 0,
	item_indent = 2,
	item_prefix_char = "",
	section_gap = 1,
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

	footer_mt = 0,
	footer_mb = 0,
	footer = function()
		return {
			"",
			"Have a productive session ✨",
		}
	end,
}

local M = {}

M.opts = {}

function M.set_opts(user_opts)
	M.opts = vim.tbl_deep_extend("force", {}, default_config, user_opts or {})
end

return M
