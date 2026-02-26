local M = {}

--- Generates the prefix string for each item based on the configuration options, including the prefix character and indentation
--- @param opts homecoming-nvim.Opts The configuration options, including item_prefix_char and item_indent
--- @returns string The prefix string to be added before each item label when rendering
function M.get_item_prefix(opts)
	local prefix_char = opts.item_prefix_char or ""
	local indent = (opts.item_indent or 2) - prefix_char:len()

	return string.rep(" ", indent) .. prefix_char
end

--- Maps the main content from the options to a list of strings to be rendered
--- @param opts homecoming-nvim.Opts The configuration options
--- @param header_line_count integer The number of lines in the header, used to calculate line numbers for items
--- @return string[] lines, homecoming-nvim.LineInfo[] lines_metadata The list of lines to be rendered and the corresponding metadata for each item line, including action, length, line number, and start column
function M.get(opts, header_line_count)
	local margin = require("homecoming-nvim.ui.components.margin")
	local utils = require("homecoming-nvim.utils")

	--- @type homecoming-nvim.LineInfo[]
	local lines_metadata = {}
	local lines = {}

	local line_num = header_line_count or #lines
	local item_prefix = M.get_item_prefix(opts)
	for j, section in ipairs(opts.sections) do
		utils.concat(lines, section.title)

		line_num = line_num + 1
		for i, item in ipairs(section.items) do
			local item_line = item_prefix .. item.label

			utils.concat(lines, item_line)
			line_num = line_num + 1

			-- Cache the line number for this item, used for navigation and actions
			table.insert(lines_metadata, {
				action = item.action,
				len = item_line:len() - (opts.item_indent or 0),
				line = line_num,
				start = 3,
			})

			margin.add_gap(lines, opts.section_gap, i < #section.items)
		end

		margin.add_gap(lines, opts.section_gap, j < #opts.sections)
	end

	return lines, lines_metadata
end
return M
