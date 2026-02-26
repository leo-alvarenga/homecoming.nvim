local M = {}

function M.get_window_size()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)

	return { width = width }
end

return M
