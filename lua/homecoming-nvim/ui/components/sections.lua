local M = {}

--- Calculates the longest length of section titles and item labels based on the provided options
--- @param opts homecoming-nvim.Opts The configuration options, including sections with titles and items with labels
--- @return integer longest_section, integer longest_item The longest length of section titles and item labels
function M.get_longest_lens(opts)
	local longest_section = 0
	local longest_item = 0

	for _, section in ipairs(opts.sections) do
		if section.title:len() > longest_section then
			longest_section = section.title:len()
		end

		for _, item in ipairs(section.items) do
			local item_length = item.label:len()

			if item_length > longest_item then
				longest_item = item_length
			end
		end
	end

	return longest_section, longest_item
end

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
--- @param win_width integer The width of the dashboard window, used for centering text if the centered option is enabled
--- @param header_width integer? An optional width to be used for calculating the padding instead of the text width, allowing for centering based on a different reference width if provided
--- @return string[] lines, homecoming-nvim.LineInfo[] lines_metadata The list of lines to be rendered and the corresponding metadata for each item line, including action, length, line number, and start column
function M.get(opts, header_line_count, win_width, header_width)
	local center = require("homecoming-nvim.ui.components.center")
	local margin = require("homecoming-nvim.ui.components.margin")
	local utils = require("homecoming-nvim.utils")

	local item_prefix = M.get_item_prefix(opts)

	local longest_section, longest_item = header_width or 0, header_width or 0

	if header_width and string.find(opts.section_anchor or "", "header") then
		if opts.section_anchor == "header_half" then
			local half = math.floor(header_width / 2)

			longest_section, longest_item = half, half
		end
	else
		longest_section, longest_item = M.get_longest_lens(opts)
	end

	longest_item = math.max(0, longest_item - item_prefix:len())

	--- @type homecoming-nvim.LineInfo[]
	local lines_metadata = {}
	local lines = {}

	local line_num = header_line_count or #lines
	for j, section in ipairs(opts.sections) do
		if opts.centered and win_width then
			utils.concat(lines, center.get_padding(longest_section, win_width) .. section.title)
		else
			utils.concat(lines, section.title)
		end

		line_num = line_num + 1
		for i, item in ipairs(section.items) do
			local padding = ""
			if opts.centered and win_width then
				padding = center.get_padding(longest_item, win_width)
			end

			local item_line = padding .. item_prefix .. item.label
			utils.concat(lines, item_line)
			line_num = line_num + 1

			local start = item_line:len()
				- (item_line:len() - padding:len() - item_prefix:len())
				- (math.max(0, opts.item_indent - 1))

			-- Cache the line number for this item, used for navigation and actions
			table.insert(lines_metadata, {
				action = item.action,
				len = item_line:len() - (opts.item_indent or 0),
				line = line_num,
				start = start,
			})

			margin.add_gap(lines, opts.item_gap, i < #section.items)
		end

		margin.add_gap(lines, opts.section_gap, j < #opts.sections)
	end

	return lines, lines_metadata
end
return M
