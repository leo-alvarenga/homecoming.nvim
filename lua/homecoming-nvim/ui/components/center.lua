local M = {}

--- Calculates the number of padding spaces needed to center the given text within a specified width
--- @param text_width integer The text to be centered
--- @param width integer The total width within which to center the text, used to calculate the padding
--- @return string padding A string consisting of the calculated number of spaces needed to center the text within the specified width
function M.get_padding(text_width, width)
	local padding = math.floor((width - text_width) / 2)

	return string.rep(" ", padding)
end

--- Centers the given text within a specified width by adding padding spaces on the left
--- @param text string The text to be centered
--- @param width integer The total width within which to center the text, used to calculate
--- @param archor_width integer? An optional width to be used for calculating the padding instead of the text width, allowing for centering based on a different reference width if provided
--- @return string txt The input text with added padding spaces on the left to center it within the specified width
function M.text(text, width, archor_width, condition)
	return M.get_padding(archor_width or vim.fn.strdisplaywidth(text), width) .. text
end

--- Centers each line in the given list of lines within a specified width by adding padding spaces on the left
--- @param lines string[] The list of lines to be centered
--- @param width integer The total width within which to center each line, used to calculate the padding for each line
--- @param archor_width integer? An optional width to be used for calculating the padding instead of the text width, allowing for centering based on a different reference width if provided
--- @return string[] centered_lines A new list of centered_lines
function M.lines(lines, width, archor_width)
	local centered_lines = {}

	for _, line in ipairs(lines) do
		table.insert(centered_lines, M.text(line, width, archor_width))
	end

	return centered_lines
end

--- Centers the given list of lines vertically within a specified height by adding empty lines as padding on the top
--- @param lines string[] The list of lines to be centered vertically
--- @param win_height integer The total height within which to center the lines
--- @return string[] centered_lines, integer padding A new list of lines with added empty lines on the top to center the original lines vertically within the specified height
function M.center_vertically(lines, win_height)
	local padding = math.max(0, math.floor((win_height - #lines) / 2))

	local centered_lines = {}
	for _ = 1, padding do
		table.insert(centered_lines, "")
	end

	vim.list_extend(centered_lines, lines)

	return centered_lines, padding
end

return M
