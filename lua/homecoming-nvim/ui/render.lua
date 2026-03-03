local consts = require("homecoming-nvim.constants")

local M = {}

--- @type homecoming-nvim.RenderState
M.state = {
	-- Neovim handles
	buf = nil,
	win = nil,
	highlight_ns = nil,

	-- Static content
	lines = {},
	hl_lines = {},
	item_lines = {},

	curr_item = 1,
}

--------------------------------
-- Basic getters and setters for state

function M.close_and_delete()
	if M.state.buf and vim.api.nvim_buf_is_valid(M.state.buf) then
		vim.api.nvim_buf_delete(M.state.buf, { force = true })
	else
		local buffers = vim.fn.getbufinfo({ buflisted = 1 })

		for _, curr_buf in ipairs(buffers) do
			if vim.api.nvim_buf_is_valid(curr_buf.bufnr) and curr_buf.name == consts.buffer_name then
				vim.api.nvim_buf_delete(curr_buf.bufnr, { force = true })
			end
		end
	end

	M.state.buf = nil
end

function M.get_buf()
	if M.state.buf and vim.api.nvim_buf_is_valid(M.state.buf) then
		return M.state.buf or 0
	end

	M.state.buf = vim.api.nvim_create_buf(false, true)
	return M.state.buf or 0
end

function M.get_win()
	if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
		return M.state.win or 0
	end

	M.state.win = vim.api.nvim_get_current_win()
	return M.state.win or 0
end

function M.get_highlight_ns()
	if M.state.highlight_ns then
		return M.state.highlight_ns or 0
	end

	M.state.highlight_ns = vim.api.nvim_create_namespace(consts.hl.namespace)
	return M.state.highlight_ns or 0
end

function M.get_win_size()
	local win = M.get_win()

	return vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win)
end

--------------------------------
-- Functions for rendering and updating the dashboard

function M.write_lines()
	local buf = M.get_buf()

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, M.state.lines)
	vim.bo[buf].modifiable = false

	vim.cmd("edit " .. consts.buffer_name)
end

function M.apply_hls()
	for _, hl_line in ipairs(M.state.hl_lines) do
		vim.hl.range(
			M.get_buf(),
			M.get_highlight_ns(),
			hl_line.hl_group,
			{ hl_line.row, hl_line.start_col },
			{ hl_line.row, hl_line.end_col }
		)
	end

	for i, item in ipairs(M.state.item_lines) do
		local hl_group = item.hl.hl_group

		if i == M.state.curr_item then
			hl_group = consts.hl.current_item
		end

		vim.hl.range(
			M.get_buf(),
			M.get_highlight_ns(),
			hl_group,
			{ item.hl.row, item.hl.start_col },
			{ item.hl.row, item.hl.end_col }
		)
	end
end

--- Renders the dashboard content centered based on the current ration, including header, sections with items, and footer
--- @param opts homecoming-nvim.Opts The configuration options for the dashboard, including header, sections, and footer
function M.render(opts)
	local adapter = require("homecoming-nvim.ui.adapter")

	local win_width, win_height = M.get_win_size()
	local res = adapter.get(opts, win_width, win_height, "homecoming")

	M.state.lines = res.lines
	M.state.hl_lines = res.hl_lines
	M.state.item_lines = res.item_lines

	M.write_lines()
	M.apply_hls()
end

--- Updates the cursor position and highlights the current item based on the current state of the dashboard
function M.update_cursor()
	local buf = M.get_buf()
	--- @type homecoming-nvim.ItemLine
	local curr_item = M.state.item_lines[M.state.curr_item or 1]

	--- @type homecoming-nvim.HlLine
	local curr_line = {
		row = 0,
		start_col = 0,
		end_col = 0,
		hl_group = "",
	}

	if curr_item then
		curr_line = curr_item.hl
	end

	vim.api.nvim_win_set_cursor(0, { curr_line.row + 1, math.max(1, curr_line.start_col) })
	vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

	M.apply_hls()
end

--- Sets up keymaps for navigating the dashboard and triggering actions
function M.set_keymaps()
	local buf = M.get_buf()

	vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

	vim.keymap.set("n", "<Down>", function()
		M.move_cursor(1)
	end, { buffer = buf })

	vim.keymap.set("n", "j", function()
		M.move_cursor(1)
	end, { buffer = buf })

	vim.keymap.set("n", "<Up>", function()
		M.move_cursor(-1)
	end, { buffer = buf })

	vim.keymap.set("n", "k", function()
		M.move_cursor(-1)
	end, { buffer = buf })

	vim.keymap.set("n", "h", function() end, { buffer = buf })
	vim.keymap.set("n", "l", function() end, { buffer = buf })
	vim.keymap.set("n", "<BS>", function() end, { buffer = buf })

	vim.keymap.set("n", "<CR>", M.execute_current_item, { buffer = buf })
end

--- Refreshes the dashboard buffer with the current configuration and state, and sets up keymaps for navigation and actions
--- @param opts homecoming-nvim.Opts The configuration options to use for rendering the dashboard, if nil it will use the current configuration
function M.refresh(opts)
	M.close_and_delete()

	local buf = M.get_buf()

	vim.api.nvim_buf_set_name(buf, consts.buffer_name)

	-- Buffer options: make it feel like a UI
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = consts.filetype

	M.render(opts)
	M.set_keymaps()

	vim.api.nvim_set_current_buf(buf)
	vim.cmd("setlocal nonumber norelativenumber nocursorline")
end

--- Moves the cursor by the given delta and updates the highlights accordingly
--- @param delta integer? The number of positions to move the cursor (positive or negative)
function M.move_cursor(delta)
	M.state.curr_item = M.state.curr_item + (delta or 0)

	local last = #M.state.item_lines

	if M.state.curr_item < 1 then
		M.state.curr_item = last
	elseif M.state.curr_item > last then
		M.state.curr_item = 1
	end

	M.update_cursor()
end

function M.execute_current_item()
	local curr_item = M.state.item_lines[M.state.curr_item]

	if not curr_item or not curr_item.action then
		-- Maybe add a notification or something here to indicate no action is available for this item?
		return
	end

	if type(curr_item.action) == "string" then
		return vim.cmd(curr_item.action)
	end

	curr_item.action()
end

--- Closes all buffers except the dashboard buffer and refreshes the dashboard, used when opening the dashboard with no file arguments to ensure a clean state
--- @param opts homecoming-nvim.Opts The configuration options to use for rendering the dashboard, if nil it will use the current configuration
function M.close_all_and_refresh(opts)
	M.refresh(opts)

	local buffers = vim.fn.getbufinfo({ buflisted = 1 })

	for _, curr_buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_valid(curr_buf.bufnr) and curr_buf.name ~= consts.buffer_name then
			vim.api.nvim_buf_delete(curr_buf.bufnr, { force = true })
		end
	end
end

M.highlights = require("homecoming-nvim.ui.highlights")

return M
