local config = require("homecoming-nvim.config")
local consts = require("homecoming-nvim.constants")
local state = require("homecoming-nvim.state")
local ui = require("homecoming-nvim.ui")

local M = {}

M.version = "0.2.0"

local function open_if_no_buffers()
	local buf_count = vim.fn.getbufinfo({ buflisted = 1 })

	if #buf_count > 2 then
		return
	end

	local has_only_empty = vim.iter(buf_count):all(function(buf)
		return #buf.name == 0
	end)

	if not has_only_empty then
		return
	end

	M.open()
end

local function close_current_buffer()
	vim.cmd("bd")
	open_if_no_buffers()
end

--- @param user_opts homecoming-nvim.Opts User-provided configuration options to customize
local function setup_autocmds(user_opts)
	if user_opts.auto_start then
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				if vim.fn.argc() == 0 then
					M.open()
				end
			end,
		})
	end
end

local function register_cmds()
	vim.api.nvim_create_user_command("Homecoming", function()
		M.open()
	end, {
		desc = "Open the Homecoming dashboard",
	})

	vim.api.nvim_create_user_command("HomecomingCloseCurrBuf", function()
		close_current_buffer()
	end, {
		desc = "Close the current buffer. If it's the last buffer, open the Homecoming dashboard",
	})

	vim.api.nvim_create_user_command("HomecomingOpenAndPreserveOther", function()
		M.open(true)
	end, {
		desc = "Open the Homecoming dashboard, preserving other buffers",
	})
end

--- @param user_opts homecoming-nvim.Opts|nil User-provided configuration options to customize
function M.setup(user_opts)
	config.set_opts(user_opts)

	ui.highlights.register_hls(config.opts)

	setup_autocmds(config.opts)
	register_cmds()
end

--- Moves the cursor by the given delta and updates the highlights accordingly
--- @param delta integer The number of positions to move the cursor (positive or negative)
local function move_cursor(delta)
	state.move(delta)

	local win_width = state.get_window_size()
	ui.update_cursor(
		state.get_buffer(),
		state.get_highlight_ns(),
		win_width,
		config.opts,
		state.get_curr_item_hl_range(config.opts),
		state.curr.lines
	)
end

--- Opens the dashboard, closing all other buffers first (toggleable, enabled by default), and sets up the buffer lines and highlights
--- @param preserve_other_buffers boolean? If true, the dashboard will be opened without closing other buffers. Defaults to false.
function M.open(preserve_other_buffers)
	local buf = state.get_buffer()
	local hl_ns = state.get_highlight_ns()
	local w, h = state.get_window_size()

	if preserve_other_buffers then
		state.set_lines(ui.refresh(buf, hl_ns, config.opts, w, h, move_cursor, state.execute_current_item))
	else
		state.set_lines(
			ui.close_all_and_refresh(buf, hl_ns, config.opts, w, h, move_cursor, state.execute_current_item)
		)
	end

	move_cursor(0) -- Ensure cursor is on the first item
end

return M
