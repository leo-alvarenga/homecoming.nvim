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

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param prev_values homecoming-nvim.AdapterResult
--- @param items homecoming-nvim.Item[]
--- @return homecoming-nvim.AdapterResult
function M._get_items(opts, win_width, prev_values, items)
	--- @type homecoming-nvim.AdapterResult
	local res = prev_values

	local line = ""
	local padding = ""
	local row = math.max(0, #res.lines - 1)

	--- @type homecoming-nvim.HlLine
	local hl_line = {
		row = row,
		start_col = 1,
		end_col = 1,
		hl_group = consts.hl.section,
	}

	for _, item in ipairs(items or {}) do
		padding = ""
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
	for _, section in ipairs(opts.sections or {}) do
		local has_content = (section.title and section.title:len() > 0) or (section.items and #section.items > 0)

		if section.title and section.title:len() > 0 then
			local line = padding .. section.title

			table.insert(res.lines, line)

			table.insert(res.hl_lines, {
				row = #res.lines,
				start_col = #padding,
				end_col = -1,
				hl_group = consts.hl.section,
			})
		end

		if section.items then
			-- Items
		end

		if has_content then
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
