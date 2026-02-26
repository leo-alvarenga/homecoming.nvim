local M = {}

--- Maps the header content from the options to a list of strings to be rendered
--- @param opts homecoming-nvim.Opts The configuration options
--- @returns string[] A list of strings representing the header content to be rendered
function M.get(opts)
	local margin = require("homecoming-nvim.ui.components.margin")
	local utils = require("homecoming-nvim.utils")

	local header = utils.get_from_str_or_fn(opts.header) or ""
	local res = {}

	utils.concat(res, header)

	return margin.add_margins(res, 0, opts.header_mb)
end

return M
