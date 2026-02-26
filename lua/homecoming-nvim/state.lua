local utils = require("homecoming-nvim.utils")

local M = {}

--- @type homecoming-nvim.DashboardState
M.curr = {
	buf = nil,
	curr_item = 1,

	highlight_ns = nil, -- Namespace for curr_item highlighting
	lines = {},
}

--- @param lines homecoming-nvim.LineInfo[] The metadata for each line corresponding to items, including action, length, line number, and start column, used for navigation and actions
function M.set_lines(lines)
	M.curr.lines = lines
end

--- Returns the dashboard buffer, creating it if it doesn't exist or is invalid
--- @returns integer Buffer handle
function M.get_buffer()
	if type(M.curr.buf) == "number" and vim.api.nvim_buf_is_valid(M.curr.buf) then
		return M.curr.buf or 0 -- 0 is here purely for type consistency, it will never actually be returned since we check validity above
	end

	local buf = vim.api.nvim_create_buf(false, true)
	M.curr.buf = buf

	return buf
end

--- Returns the highlight namespace for the dashboard, creating it if it doesn't exist
--- @returns integer Namespace handle
function M.get_highlight_ns()
	if M.curr.highlight_ns then
		return M.curr.highlight_ns or 0 -- 0 is here purely for type consistency, it will never actually be returned since we check existence above
	end

	local highlight_ns = vim.api.nvim_create_namespace("homecoming_dashboard")
	M.curr.highlight_ns = highlight_ns

	return highlight_ns
end

--- Deletes the dashboard buffer if it exists and is valid, and clears the buffer reference in the state
function M.delete_buffer()
	if M.curr.buf and vim.api.nvim_buf_is_valid(M.curr.buf) then
		vim.api.nvim_buf_delete(M.curr.buf, { force = true })
	end

	M.curr.buf = nil
end

--- Returns the line and column range for highlighting the current item, based on the cached line information for the current item
--- @return homecoming-nvim.LineHlRange range The line and column range for highlighting the current item, used for navigation and actions
function M.get_curr_item_hl_range()
	local line_info = M.curr.lines[M.curr.curr_item] or {}

	local start_col = (line_info.start or 1) - 1
	local end_col = start_col + (line_info.len or 1)

	return {
		line = line_info.line or 1,
		start_col = start_col,
		end_col = end_col,
	}
end

--- Moves the curr_item by a given delta, wrapping around the list of items if necessary
--- @param delta integer The number of positions to move the curr_item (positive or negative)
--- @returns integer The new curr_item position after moving
function M.move(delta)
	M.curr.curr_item = M.curr.curr_item + delta

	local last = #M.curr.lines

	if M.curr.curr_item < 1 then
		M.curr.curr_item = last
	elseif M.curr.curr_item > last then
		M.curr.curr_item = 1
	end

	return M.curr.curr_item
end

--- Executes the action associated with the current item, if it exists, by looking up the cached line information for the current item and calling the appropriate function or Vim command
--- If the current item does not have an associated action, this function does nothing
function M.execute_current_item()
	local item = M.curr.lines[M.curr.curr_item]

	if not item then
		return
	end

	utils.execute_action(item.action)
end

return M
