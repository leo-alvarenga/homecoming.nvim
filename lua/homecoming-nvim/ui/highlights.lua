local M = {}

--- Registers highlight groups for the dashboard, allowing for consistent styling of the dashboard's header, sections, and footer
--- @param opts homecoming-nvim.Opts The configuration options for the dashboard
function M.register_hls(opts)
	local consts = require("homecoming-nvim.constants")

	vim.api.nvim_set_hl(0, consts.hl.current_item, { default = true, link = opts.item_selected_hl_group or "Normal" })
	vim.api.nvim_set_hl(0, consts.hl.footer, { default = true, link = opts.footer_hl_group or "ErrorMsg" })
	vim.api.nvim_set_hl(0, consts.hl.header, { default = true, link = opts.header_hl_group or "Title" })
	vim.api.nvim_set_hl(0, consts.hl.item, { default = true, link = opts.item_hl_group or "Comment" })
	vim.api.nvim_set_hl(0, consts.hl.section, { default = true, link = opts.section_hl_group or "Delimiter" })
end

return M
