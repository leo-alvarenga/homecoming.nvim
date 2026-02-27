local M = {}

function M.check()
	vim.health.start("homecoming.nvim")
	vim.health.ok("Plugin loaded successfully; homecoming.nvim is working")

	local ok, homecoming = pcall(require, "homecoming-nvim")

	if ok and homecoming then
		if not homecoming.version or not homecoming.open then
			vim.health.warn(
				"Some functions are missing from the plugin. Please ensure you have the latest version of homecoming.nvim installed."
			)
		else
			vim.health.ok("All expected functions are present in homecoming.nvim")
		end
	else
		vim.health.error("Failed to load homecoming.nvim. Please ensure it is installed and properly configured.")
	end
end

return M
