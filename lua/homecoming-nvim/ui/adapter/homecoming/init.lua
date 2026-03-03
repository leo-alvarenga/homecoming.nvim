local M = {}

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param win_height integer
--- @return homecoming-nvim.AdapterResult
function M.get(opts, win_width, win_height)
	local helpers = require("homecoming-nvim.ui.adapter.homecoming.helpers")

	local header = require("homecoming-nvim.ui.adapter.homecoming.header")
	local sections = require("homecoming-nvim.ui.adapter.homecoming.sections")
	local footer = require("homecoming-nvim.ui.adapter.homecoming.footer")

	--- @type homecoming-nvim.AdapterResult
	local res = {
		header_width = 0,
		hl_lines = {},
		item_lines = {},
		lines = {},
	}

	res = header.get(opts, win_width)
	res = sections.get(opts, win_width, res)
	res = footer.get(opts, win_width, res)

	local padding = 0
	res.lines, padding = helpers.center_vertically(res.lines, win_height)

	-- Adjust hl_lines and item_lines row numbers based on the added padding
	for i in ipairs(res.hl_lines) do
		res.hl_lines[i].row = res.hl_lines[i].row + padding
	end

	for i in ipairs(res.item_lines) do
		res.item_lines[i].hl.row = res.item_lines[i].hl.row + padding
	end

	return res
end

return M
