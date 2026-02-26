local consts = require("homecoming-nvim.constants")
local utils = require("homecoming-nvim.utils")

local M = {}

--- Writes the given list of lines to the specified buffer, making the buffer modifiable temporarily to set the lines and then setting it back to non-modifiable
--- @param buf integer The buffer handle to which the lines will be written, used to set
--- @param lines string[] The list of lines to be written to the buffer, used as the content for the dashboard
function M.write_lines(buf, lines)
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.cmd("edit " .. consts.buffer_name)
end

--- Renders the dashboard content centered based on the current ration, including header, sections with items, and footer
--- @param buf integer The buffer handle for the dashboard, used to set the buffer lines with the rendered content
--- @param opts homecoming-nvim.Opts The configuration options for the dashboard, including header, sections, and footer
--- @param win_width integer The width of the dashboard window, used for centering text if the centered option is enabled
--- @param win_height integer The width of the dashboard window, used for centering text if the centered option is enabled
--- @return homecoming-nvim.LineInfo[] lines_metadata The list of lines to be rendered and the corresponding metadata for each item line, including action, length, line number, and start column
function M.render(buf, opts, win_width, win_height)
	local components = require("homecoming-nvim.ui.components")
	local lines = {}

	local header = components.header.get(opts)
	utils.concat(lines, components.center.lines(header, win_width))

	local header_width = 0

	for _, line in ipairs(header) do
		header_width = math.max(header_width, vim.fn.strdisplaywidth(line))
	end

	local sections, line_metadata = components.sections.get(opts, #lines, win_width, header_width)
	utils.concat(lines, sections)

	local footer_anchor = nil
	if opts.footer_anchor == "header" then
		footer_anchor = header_width
	elseif opts.footer_anchor == "header_half" then
		footer_anchor = math.max(0, math.floor(header_width / 2))
	end

	utils.concat(lines, components.center.lines(components.footer.get(opts), win_width, footer_anchor))

	local padding = 0
	lines, padding = components.center.center_vertically(lines, win_height)

	for i in ipairs(line_metadata) do
		line_metadata[i].line = line_metadata[i].line + padding
	end

	M.write_lines(buf, lines)
	return line_metadata
end

--- Updates the cursor position and highlights the current item based on the current state of the dashboard
--- @param buf integer The buffer handle for the dashboard, used to set the cursor position and apply highlights
--- @param hl_ns integer The highlight namespace handle for the dashboard, used to apply highlights to the current item
--- @param range homecoming-nvim.LineHlRange The line and column range for highlighting
function M.update_cursor(buf, hl_ns, range)
	vim.api.nvim_win_set_cursor(0, { range.line, math.max(1, range.start_col) - 1 })
	vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

	vim.hl.range(buf, hl_ns, "Search", { range.line - 1, range.start_col }, { range.line - 1, range.end_col })
end

--- Sets up keymaps for navigating the dashboard and triggering actions
--- @param buf integer The buffer handle for the dashboard, used to set buffer-local keymaps
--- @param move_cursor_fn function A function that takes a delta and updates the cursor position and highlights accordingly, used as the callback for navigation keymaps
--- @param execute_action_fn function A function that executes the action for the currently selected item, used as the callback for the Enter keymap
function M.set_keymaps(buf, move_cursor_fn, execute_action_fn)
	vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)

	vim.keymap.set("n", "<Down>", function()
		move_cursor_fn(1)
	end, { buffer = buf })

	vim.keymap.set("n", "j", function()
		move_cursor_fn(1)
	end, { buffer = buf })

	vim.keymap.set("n", "<Up>", function()
		move_cursor_fn(-1)
	end, { buffer = buf })

	vim.keymap.set("n", "k", function()
		move_cursor_fn(-1)
	end, { buffer = buf })

	vim.keymap.set("n", "h", function() end, { buffer = buf })
	vim.keymap.set("n", "l", function() end, { buffer = buf })
	vim.keymap.set("n", "<BS>", function() end, { buffer = buf })
	vim.keymap.set("n", "<CR>", execute_action_fn, { buffer = buf })
end

--- Refreshes the dashboard buffer with the current configuration and state, and sets up keymaps for navigation and actions
--- @param buf integer The buffer handle for the dashboard, if nil it will be
--- @param opts homecoming-nvim.Opts The configuration options to use for rendering the dashboard, if nil it will use the current configuration
--- @param win_width integer The width of the dashboard window, used for centering text if the centered option is enabled
--- @param move_cursor_fn function A function that takes a delta and updates the cursor position and highlights accordingly, used as the callback for navigation keymaps
--- @param win_height integer The width of the dashboard window, used for centering text if the centered option is enabled
--- @param execute_action_fn function A function that executes the action for the currently selected item, used as the callback for the Enter keymap
--- @return homecoming-nvim.LineInfo[] lines_metadata The list of lines to be rendered and the corresponding metadata for each item line, including action, length, line number, and start column
function M.refresh(buf, opts, win_width, win_height, move_cursor_fn, execute_action_fn)
	vim.api.nvim_buf_set_name(buf, consts.buffer_name)

	-- Buffer options: make it feel like a UI
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "dashboard"

	local lines_metadata = M.render(buf, opts, win_width, win_height)
	M.set_keymaps(buf, move_cursor_fn, execute_action_fn)

	vim.cmd("setlocal nonumber norelativenumber nocursorline")

	return lines_metadata
end

--- Closes all buffers except the dashboard buffer and refreshes the dashboard, used when opening the dashboard with no file arguments to ensure a clean state
--- @param buf integer The buffer handle for the dashboard, if nil it will be
--- @param opts homecoming-nvim.Opts The configuration options to use for rendering the dashboard, if nil it will use the current configuration
--- @param win_width integer The width of the dashboard window, used for centering text if the centered option is enabled
--- @param win_height integer The width of the dashboard window, used for centering text if the centered option is enabled
--- @param move_cursor_fn function A function that takes a delta and updates the cursor position and highlights accordingly, used as the callback for navigation keymaps
--- @param execute_action_fn function A function that executes the action for the currently selected item, used as the callback for the Enter keymap
--- @return homecoming-nvim.LineInfo[] lines_metadata The list of lines to be rendered and the corresponding metadata for each item line, including action, length, line number, and start column
function M.close_all_and_refresh(buf, opts, win_width, win_height, move_cursor_fn, execute_action_fn)
	local lines_metadata = M.refresh(buf, opts, win_width, win_height, move_cursor_fn, execute_action_fn)

	local buffers = vim.fn.getbufinfo({ buflisted = 1 })

	for _, curr_buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_valid(curr_buf.bufnr) and curr_buf.name ~= consts.buffer_name then
			vim.api.nvim_buf_delete(curr_buf.bufnr, { force = true })
		end
	end

	return lines_metadata
end

M.highlights = require("homecoming-nvim.ui.highlights")

return M
