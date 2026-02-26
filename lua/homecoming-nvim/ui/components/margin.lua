local M = {}

--- Adds top and bottom margins to the given lines based on the specified margin sizes
--- @param lines string[] The list of lines to which margins should be added
--- @param mt integer|nil The size of the top margin (number of empty lines to add at the beginning)
--- @param mb integer|nil The size of the bottom margin (number of empty lines to add at the end)
--- @returns string[] A new list of lines with the specified top and bottom margins added
function M.add_margins(lines, mt, mb)
	local res = {}

	for _ = 1, mt or 0 do
		table.insert(res, "")
	end

	for _, line in ipairs(lines) do
		table.insert(res, line)
	end

	for _ = 1, mb or 0 do
		table.insert(res, "")
	end

	return res
end

--- Adds a gap between lines by inserting empty lines based on the specified gap size
--- @param lines string[] The list of lines to which the gap should be added
--- @param gap integer|nil The size of the gap
--- @return string[] res A new list of lines with the specified gap added if enabled, otherwise the original lines
function M.add_gap(lines, gap)
	if gap < 1 then
		return lines
	end

	return M.add_margins(lines, 0, gap)
end

return M
