local consts = require("homecoming-nvim.constants")
local utils = require("homecoming-nvim.utils")

local M = {}

--- Maps the header content from the options to a list of strings to be rendered
--- @param opts homecoming-nvim.Opts The configuration options
--- @returns string[] A list of strings representing the header content to be rendered
function M.get_header(opts)
	local header = utils.get_from_str_or_fn(opts.header) or ""
	local res = {}

	utils.concat(res, header)

	for _ = 1, opts.header_mb or 0 do
		table.insert(res, "")
	end

	return res
end

--- Maps the header content from the options to a list of strings to be rendered
--- @param opts homecoming-nvim.Opts The configuration options
--- @returns string[] A list of strings representing the header content to be rendered
function M.get_footer(opts)
	local footer = utils.get_from_str_or_fn(opts.footer) or ""
	local res = {}

	for _ = 1, opts.footer_mt or 0 do
		table.insert(res, "")
	end

	utils.concat(res, footer)

	for _ = 1, opts.header_mb or 0 do
		table.insert(res, "")
	end

	return res
end

--- Generates the prefix string for each item based on the configuration options, including the prefix character and indentation
--- @param opts homecoming-nvim.Opts The configuration options, including item_prefix_char and item_indent
--- @returns string The prefix string to be added before each item label when rendering
function M.get_item_prefix(opts)
	local prefix_char = opts.item_prefix_char or ""
	local indent = (opts.item_indent or 2) - prefix_char:len()

	return string.rep(" ", indent) .. prefix_char
end

--- Renders the dashboard content based on the current ration, including header, sections with items, and footer
--- @param buf integer The buffer handle for the dashboard, used to set the buffer lines with the rendered content
--- @param opts homecoming-nvim.Opts The configuration options for the dashboard, including header, sections, and footer
--- @param state homecoming-nvim.DashboardState The current state of the dashboard, used to cache
function M.render(buf, opts, state)
	local lines = {}
	utils.concat(lines, M.get_header(opts))

	local line_num = #lines
	local item_prefix = M.get_item_prefix(opts)
	for j, section in ipairs(opts.sections) do
		table.insert(lines, section.title)

		line_num = line_num + 1
		for i, item in ipairs(section.items) do
			local item_line = item_prefix .. item.label

			table.insert(lines, item_line)
			line_num = line_num + 1

			-- Cache the line number for this item, used for navigation and actions
			table.insert(state.lines, {
				action = item.action,
				len = item_line:len() - (opts.item_indent or 0),
				line = line_num,
				start = 3,
			})

			if i < #section.items then
				for _ = 1, opts.item_gap or 0 do
					table.insert(lines, "")
					line_num = line_num + 1
				end
			end
		end

		if j < #opts.sections then
			for _ = 1, opts.section_gap or 0 do
				table.insert(lines, "")
				line_num = line_num + 1
			end
		end
	end

	utils.concat(lines, M.get_footer(opts))

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.cmd("edit " .. consts.buffer_name)
end

--- Updates the cursor position and highlights the current item based on the current state of the dashboard
--- @param buf integer The buffer handle for the dashboard, used to set the cursor position and apply highlights
--- @param hl_ns integer The highlight namespace handle for the dashboard, used to apply highlights to the current item
--- @param range homecoming-nvim.LineHlRange The line and column range for highlighting
function M.update_cursor(buf, hl_ns, range)
	vim.api.nvim_win_set_cursor(0, { range.line, range.start_col - 1 })
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

	vim.keymap.set("n", "<BS>", function() end, { buffer = buf })
	vim.keymap.set("n", "<CR>", execute_action_fn, { buffer = buf })
end

return M
