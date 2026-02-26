local config = require("homecoming-nvim.config")
local state = require("homecoming-nvim.state")
local ui = require("homecoming-nvim.ui")

local M = {}

--- @param user_opts homecoming-nvim.Opts|nil User-provided configuration options to customize
function M.setup(user_opts)
	config.set_opts(user_opts)

	if config.opts.auto_start then
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				if vim.fn.argc() == 0 then
					M.open(true)
				end
			end,
		})
	end
end

--- Moves the cursor by the given delta and updates the highlights accordingly
--- @param delta integer The number of positions to move the cursor (positive or negative)
local function move_cursor(delta)
	state.move(delta)
	ui.update_cursor(state.get_buffer(), state.get_highlight_ns(), state.get_curr_item_hl_range())
end

function M.open(close_all)
	local buf = state.get_buffer()
	local w, h = state.get_window_size()
	if close_all then
		state.set_lines(ui.close_all_and_refresh(buf, config.opts, w, h, move_cursor, state.execute_current_item))
	else
		state.set_lines(ui.refresh(buf, config.opts, w, h, move_cursor, state.execute_current_item))
	end

	move_cursor(0) -- Ensure cursor is on the first item
end

return M
