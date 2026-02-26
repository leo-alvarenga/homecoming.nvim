local M = {}

--- Registers highlight groups for the dashboard, allowing for consistent styling of the dashboard's header, sections, and footer
--- @param ns_id integer The highlight namespace handle for the dashboard, used to apply highlights to the dashboard's components
function M.register_hls(ns_id)
	local consts = require("homecoming-nvim.constants")

	vim.api.nvim_set_hl(ns_id, consts.highlights.current_item, { link = "Search", underline = true, bold = true })
end

return M
