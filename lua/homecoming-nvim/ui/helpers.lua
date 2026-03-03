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

return M
