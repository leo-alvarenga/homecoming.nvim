local M = {}

--- Safely get a string list from either string(s) or a function that returns string(s)
--- @param str_or_fn string|string[]|function|nil
--- @return string[] res
function M.unsure_to_table(str_or_fn)
	if type(str_or_fn) == "string" then
		return { str_or_fn }
	end

	if type(str_or_fn) == "table" then
		return str_or_fn
	end

	if type(str_or_fn) == "function" then
		local val = str_or_fn()

		if type(val) == "string" then
			return { val }
		end

		if type(val) == "table" then
			return val
		end
	end

	return {}
end

return M
