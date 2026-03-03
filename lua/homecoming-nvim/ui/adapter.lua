local components = require("homecoming-nvim.ui.components")
local helpers = require("homecoming-nvim.ui.helpers")
local consts = require("homecoming-nvim.constants")
local utils = require("homecoming-nvim.utils")

local M = {}

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @return homecoming-nvim.AdapterResult
function M._get_header(opts, win_width)
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
		padding = components.center.get_padding(
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

	res.lines = components.margin.add_margins(res.lines, nil, opts.header_mb)

	return res
end

--- @param win_width integer
--- @param prev_values homecoming-nvim.AdapterResult
--- @param items homecoming-nvim.Item[]
--- @param item_prefix string
--- @param longest_item_len integer
--- @param section_anchor integer?
--- @return homecoming-nvim.AdapterResult
function M._get_items(win_width, prev_values, items, item_prefix, longest_item_len, section_anchor)
	--- @type homecoming-nvim.AdapterResult
	local res = prev_values

	local line = ""
	local padding = components.center.get_padding(longest_item_len, win_width, section_anchor)

	for _, item in ipairs(items or {}) do
		line = padding .. item_prefix .. item.label

		table.insert(res.lines, line)

		table.insert(
			res.item_lines,
			--- @type homecoming-nvim.ItemLine
			{
				action = item.action,
				label = item.label,
				hl = {
					row = #res.lines - 1,
					start_col = #padding,
					end_col = -1,
					hl_group = consts.hl.item,
				},
			}
		)
	end

	return res
end

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param prev_values homecoming-nvim.AdapterResult
--- @return homecoming-nvim.AdapterResult
function M._get_sections(opts, win_width, prev_values)
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

	local padding = components.center.get_padding(longest_section, win_width, section_anchor)
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
			res = M._get_items(
				win_width,
				res,
				section.items,
				item_prefix,
				longest_item,
				opts.section_anchor == "self" and longest_section or section_anchor
			)
		end

		if has_content and i < #opts.sections then
			res.lines = components.margin.add_gap(res.lines, opts.section_gap)
		end
	end

	return res
end

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param prev_values homecoming-nvim.AdapterResult
--- @return homecoming-nvim.AdapterResult
function M._get_footer(opts, win_width, prev_values)
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

	res.lines = components.margin.add_gap(res.lines, opts.footer_mt)

	for _, line in ipairs(footer) do
		padding = components.center.get_padding(vim.fn.strdisplaywidth(line), win_width, footer_anchor)

		table.insert(res.lines, padding .. line)
		table.insert(res.hl_lines, {
			row = #res.lines - 1,
			start_col = #padding,
			end_col = #padding + #line,
			hl_group = consts.hl.footer,
		})
	end

	res.lines = components.margin.add_gap(res.lines, opts.footer_mb)

	return res
end

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param win_height integer
--- @return homecoming-nvim.AdapterResult
function M.get(opts, win_width, win_height)
	--- @type homecoming-nvim.AdapterResult
	local res = {
		header_width = 0,
		hl_lines = {},
		item_lines = {},
		lines = {},
	}

	res = M._get_header(opts, win_width)
	res = M._get_sections(opts, win_width, res)
	res = M._get_footer(opts, win_width, res)

	local padding = 0
	res.lines, padding = components.center.center_vertically(res.lines, win_height)

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
