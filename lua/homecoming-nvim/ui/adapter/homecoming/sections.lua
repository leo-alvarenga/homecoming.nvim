local M = {}

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param prev_values homecoming-nvim.AdapterResult
--- @return homecoming-nvim.AdapterResult
function M.get(opts, win_width, prev_values)
	local helpers = require("homecoming-nvim.ui.adapter.homecoming.helpers")
	local items = require("homecoming-nvim.ui.adapter.homecoming.items")
	local consts = require("homecoming-nvim.constants")

	--- @type homecoming-nvim.AdapterResult
	local res = prev_values

	local item_prefix = helpers.get_item_prefix(opts)
	local longest_section, longest_item = helpers.get_longest_lens(opts)

	local section_anchor = res.header_width
	if opts.section_anchor == "self" then
		section_anchor = longest_section
		longest_item = math.max(0, longest_item - item_prefix:len())
	elseif opts.section_anchor == "header_half" then
		section_anchor = math.max(0, math.floor(res.header_width / 2))
	end

	local padding = helpers.get_padding(longest_section, win_width, section_anchor)
	for i, section in ipairs(opts.sections or {}) do
		local has_title = (section.title and section.title:len() > 0)
		local has_items = (section.items and #section.items > 0)
		local has_content = has_title or has_items

		if has_title then
			local line = padding .. section.title

			table.insert(res.lines, line)

			table.insert(res.hl_lines, {
				row = #res.lines - 1,
				start_col = #padding,
				end_col = -1,
				hl_group = consts.hl.section,
			})
		end

		if has_items then
			res = items.get(
				win_width,
				res,
				section.items,
				item_prefix,
				longest_item,
				opts.section_anchor == "self" and longest_section or section_anchor
			)
		end

		if has_content and i < #opts.sections then
			res.lines = helpers.add_gap(res.lines, opts.section_gap)
		end
	end

	return res
end

return M
