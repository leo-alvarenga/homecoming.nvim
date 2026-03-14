local M = {}

--- @param win_width integer
--- @param prev_values homecoming-nvim.AdapterResult
--- @param items homecoming-nvim.Item[]
--- @param item_prefix string
--- @param longest_item_len integer
--- @param section_anchor integer?
--- @return homecoming-nvim.AdapterResult
function M.get(win_width, prev_values, items, item_prefix, longest_item_len, section_anchor)
	local helpers = require("homecoming-nvim.ui.adapter.homecoming.helpers")
	local consts = require("homecoming-nvim.constants")

	--- @type homecoming-nvim.AdapterResult
	local res = prev_values

	local line = ""
	local padding = helpers.get_padding(longest_item_len, win_width, section_anchor)

	for _, item in ipairs(items or {}) do
		line = padding .. item_prefix .. item.label

		table.insert(res.lines, line)

		table.insert(
			res.item_lines,
			--- @type homecoming-nvim.ItemLine
			{
				action = item.action,
				cursor_col = #padding,
				label = item.label,
				hl = {
					row = #res.lines - 1,
					start_col = #padding + #item_prefix,
					end_col = -1,
					hl_group = consts.hl.item,
				},
			}
		)
	end

	return res
end

return M
