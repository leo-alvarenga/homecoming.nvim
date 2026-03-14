local config = require("homecoming-nvim.config")
local ui = require("homecoming-nvim.ui")

local M = {}

M.patch = "0"
M.minor = "2"
M.major = "2"

M.version = string.format("%s.%s.%s", M.major, M.minor, M.patch)

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
	local consts = require("homecoming-nvim.constants")

	vim.api.nvim_create_user_command(consts.cmd.open.cmd, function()
		M.open()
	end, {
		desc = consts.cmd.open.desc,
	})

	vim.api.nvim_create_user_command(consts.cmd.close_curr_buf.cmd, function()
		close_current_buffer()
	end, {
		desc = consts.cmd.close_curr_buf.desc,
	})

	vim.api.nvim_create_user_command(consts.cmd.open_and_preserve_other.cmd, function()
		M.open(true)
	end, {
		desc = consts.cmd.open_and_preserve_other.desc,
	})
end

--- @param user_opts homecoming-nvim.Opts|nil User-provided configuration options to customize
function M.setup(user_opts)
	config.set_opts(user_opts)

	ui.highlights.register_hls(config.opts)

	setup_autocmds(config.opts)
	register_cmds()
end

--- Opens the dashboard, closing all other buffers first (toggleable, enabled by default), and sets up the buffer lines and highlights
--- @param preserve_other_buffers boolean? If true, the dashboard will be opened without closing other buffers. Defaults to false.
function M.open(preserve_other_buffers)
	if preserve_other_buffers then
		ui.refresh(config.opts)
	else
		ui.close_all_and_refresh(config.opts)
	end

	ui.move_cursor(0)
end

return M
