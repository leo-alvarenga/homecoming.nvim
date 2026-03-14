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
--- @return string prefix The prefix string to be added before each item label when rendering
function M.get_item_prefix(opts)
	local prefix_char = opts.item_prefix_char or ""
	local indent = (opts.item_indent or 2) - prefix_char:len()

	return string.rep(" ", indent) .. prefix_char
end

--- Adds a gap (N empty lines) at the end of a list of string
--- @param lines string[] The list of lines to which the gap should be added
--- @param gap integer|nil The size of the gap
--- @return string[] res A new list of lines with the specified gap added if enabled, otherwise the original lines
function M.add_gap(lines, gap)
	if not gap or gap < 1 then
		return lines
	end

	local res = {}

	for _, line in ipairs(lines) do
		table.insert(res, line)
	end

	for _ = 1, gap do
		table.insert(res, "")
	end

	return res
end

--- Calculates the number of padding spaces needed to center the given text within a specified width
--- @param text_width integer The text to be centered
--- @param width integer The total width within which to center the text, used to calculate the padding
--- @param archor_width integer? An optional width to be used for calculating the padding instead of the text width, allowing for centering based on a different reference width if provided
--- @return string padding A string consisting of the calculated number of spaces needed to center the text within the specified width
function M.get_padding(text_width, width, archor_width)
	local padding = math.floor((width - (archor_width or text_width)) / 2)

	return string.rep(" ", padding)
end

--- Centers the given list of lines vertically within a specified height by adding empty lines as padding on the top
--- @param lines string[] The list of lines to be centered vertically
--- @param win_height integer The total height within which to center the lines
--- @return string[] centered_lines, integer padding A new list of lines with added empty lines on the top to center the original lines vertically within the specified height
function M.center_vertically(lines, win_height)
	local padding = math.max(0, math.ceil((win_height - #lines) / 2))

	local centered_lines = {}
	for _ = 1, padding do
		table.insert(centered_lines, "")
	end

	vim.list_extend(centered_lines, lines)

	return centered_lines, padding
end

return M
