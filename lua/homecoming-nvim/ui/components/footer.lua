local M = {}

--- Maps the footer content from the options to a list of strings to be rendered
--- @param opts homecoming-nvim.Opts The configuration options
--- @return string[] footer A list of strings representing the footer content to be rendered
function M.get(opts)
	local margin = require("homecoming-nvim.ui.components.margin")
	local utils = require("homecoming-nvim.utils")

	local footer = utils.get_from_str_or_fn(opts.footer) or ""
	local res = {}

	utils.concat(res, footer)

	return margin.add_margins(res, opts.footer_mt, opts.footer_mb)
end

return M
