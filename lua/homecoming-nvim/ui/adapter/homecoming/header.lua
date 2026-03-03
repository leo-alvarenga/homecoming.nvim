local M = {}

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @return homecoming-nvim.AdapterResult
function M.get(opts, win_width)
	local helpers = require("homecoming-nvim.ui.adapter.homecoming.helpers")
	local consts = require("homecoming-nvim.constants")
	local utils = require("homecoming-nvim.utils")

	--- @type homecoming-nvim.AdapterResult
	local res = {
		header_width = 0,
		hl_lines = {},
		item_lines = {}, -- Kept for consistency
		lines = {},
	}

	local header = utils.unsure_to_table(opts.header)

	for _, line in ipairs(header) do
		res.header_width = math.max(res.header_width, vim.fn.strdisplaywidth(line))
	end

	local padding = ""
	for _, line in ipairs(header) do
		padding = helpers.get_padding(
			vim.fn.strdisplaywidth(line),
			win_width,
			opts.header_centered and res.header_width or nil
		)

		table.insert(res.lines, padding .. line)

		table.insert(res.hl_lines, {
			row = math.max(0, #res.lines - 1),
			start_col = #padding,
			end_col = -1,
			hl_group = consts.hl.header,
		})
	end

	res.lines = helpers.add_gap(res.lines, opts.header_mb)

	return res
end

return M
