local utils = require("homecoming-nvim.utils")
local components = require("homecoming-nvim.ui.components")
local consts = require("homecoming-nvim.constants")

local M = {}

--- @param opts homecoming-nvim.Opts
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
	for i, line in ipairs(header) do
		padding = components.center.get_padding(
			vim.fn.strdisplaywidth(line),
			win_width,
			opts.header_centered and res.header_width or nil
		)

		--- @type homecoming-nvim.HlLine
		local hl_line = {
			row = i,
			start_col = #padding,
			end_col = #padding + #line,
			hl_group = consts.hl.header,
		}

		table.insert(res.lines, padding .. line)
		table.insert(res.hl_lines, hl_line)
	end

	res.lines = components.margin.add_margins(res.lines, nil, opts.header_mb)
	return res
end

--- @param opts homecoming-nvim.Opts
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
	local start_row = #res.lines + (opts.footer_mt or 0) - 2

	for i, line in ipairs(footer) do
		padding = components.center.get_padding(vim.fn.strdisplaywidth(line), win_width, footer_anchor)

		--- @type homecoming-nvim.HlLine
		local hl_line = {
			row = start_row + i,
			start_col = #padding,
			end_col = #padding + #line,
			hl_group = consts.hl.footer,
		}

		table.insert(res.lines, padding .. line)
		table.insert(res.hl_lines, hl_line)
	end

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
	res = M._get_footer(opts, win_width, res)

	local padding = 0
	res.lines, padding = components.center.center_vertically(res.lines, win_height)

	for i in ipairs(res.hl_lines) do
		res.hl_lines[i].row = res.hl_lines[i].row + padding
	end

	for i in ipairs(res.item_lines) do
		res.item_lines[i].hl.row = res.item_lines[i].hl.row + padding
	end

	return res
end

return M
