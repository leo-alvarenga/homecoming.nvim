local M = {}

--- @param opts homecoming-nvim.Opts
--- @param win_width integer
--- @param win_height integer
--- @param adapter homecoming-nvim.Adapter?nil Defaults to 'homecoming' adapter if not provided
--- @return homecoming-nvim.AdapterResult
function M.get(opts, win_width, win_height, adapter)
	if adapter == nil or adapter == "homecoming" then
		local homecoming_adapter = require("homecoming-nvim.ui.adapter.homecoming")

		return homecoming_adapter.get(opts, win_width, win_height)
	end

	return {
		header_width = 0,
		hl_lines = {},
		item_lines = {},
		lines = {},
	}
end

return M
