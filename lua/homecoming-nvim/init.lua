local config = require("homecoming-nvim.config")
local consts = require("homecoming-nvim.constants")
local state = require("homecoming-nvim.state")
local ui = require("homecoming-nvim.ui")

local M = {}

--- @param user_opts homecoming-nvim.Opts|nil User-provided configuration options to customize
function M.setup(user_opts)
	config.set_opts(user_opts)

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			if vim.fn.argc() == 0 then
				M.open()
			end
		end,
	})
end

--- Moves the cursor by the given delta and updates the highlights accordingly
--- @param delta integer The number of positions to move the cursor (positive or negative)
local function move_cursor(delta)
	state.move(delta)
	ui.update_cursor(state.get_buffer(), state.get_highlight_ns(), state.get_curr_item_hl_range())
end

function M.refresh()
	local buf = state.get_buffer()
	vim.api.nvim_buf_set_name(buf, consts.buffer_name)

	-- Buffer options: make it feel like a UI
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "dashboard"

	ui.render(buf, config.opts, state.curr)
	ui.set_keymaps(buf, move_cursor, state.execute_current_item)

	vim.cmd("setlocal nonumber norelativenumber nocursorline")
end

function M.open()
	M.refresh()
	move_cursor(0) -- Ensure cursor is on the first item
end

return M
