local M = {}

--- Safely get a string value from either string(s) or a function that returns string(s)
--- @param str_or_fn string|string[]|function|nil A string(s) or a function that returns string(s)
--- @returns string|nil The string value, or nil if the input was invalid
function M.get_from_str_or_fn(str_or_fn)
	if type(str_or_fn) == "function" then
		local val = str_or_fn()

		if type(val) == "string" or type(val) == "table" then
			return val
		end
	elseif type(str_or_fn) == "string" or type(str_or_fn) == "table" then
		return str_or_fn
	end

	return nil
end

--- Trims leading whitespace from a string
--- @param s string The string to trim
--- @return string s The trimmed string
function M.trim_end(s)
	if type(s) ~= "string" or s:len() < 2 then
		return s
	end

	return s:match("^(.-)%s*$")
end

--- Concatenates a value or list of values to a table
--- @param tab table The table to concatenate into
--- @param val string|string[] A single value or a list of values to concatenate into the table
function M.concat(tab, val)
	if type(val) == "table" then
		for _, v in ipairs(val) do
			if type(v) == "string" then
				table.insert(tab, M.trim_end(v))
			end
		end
	elseif type(val) == "string" then
		table.insert(tab, M.trim_end(val))
	end
end

--- Executes an action which can be either a function or a Vim command string
--- @param action function|string The action to execute, either a function to call or a Vim command string to execute with vim.cmd
function M.execute_action(action)
	if type(action) == "function" then
		action()
	elseif type(action) == "string" then
		vim.cmd(action)
	end
end

return M
