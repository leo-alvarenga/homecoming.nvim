local M = {}

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param prev_values homecoming-nvim.AdapterResult
--- @return homecoming-nvim.AdapterResult
function M.get(opts, win_width, prev_values)
	local helpers = require("homecoming-nvim.ui.adapter.homecoming.helpers")
	local consts = require("homecoming-nvim.constants")
	local utils = require("homecoming-nvim.utils")

	--- @type homecoming-nvim.AdapterResult
	local res = prev_values

	local footer = utils.unsure_to_table(opts.footer)

	local footer_anchor = nil
	if opts.footer_anchor == "header" then
		footer_anchor = res.header_width
	elseif opts.footer_anchor == "header_half" then
		footer_anchor = math.max(0, math.floor(res.header_width / 2))
	end

	local padding = ""

	res.lines = helpers.add_gap(res.lines, opts.footer_mt)

	for _, line in ipairs(footer) do
		padding = helpers.get_padding(vim.fn.strdisplaywidth(line), win_width, footer_anchor)

		table.insert(res.lines, padding .. line)
		table.insert(res.hl_lines, {
			row = #res.lines - 1,
			start_col = #padding,
			end_col = #padding + #line,
			hl_group = consts.hl.footer,
		})
	end

	res.lines = helpers.add_gap(res.lines, opts.footer_mb)

	return res
end

return M
