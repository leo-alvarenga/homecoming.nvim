-- This is an example of how to configure homecoming.nvim with lazy.nvim

local sections = {
	files = "> Files",
	config = ">  Config",
	plugins = "> Plugins and LSPs",
	exit = ">  Exit",
}

return {
	"leo-alvarenga/homecoming.nvim",
	branch = "nightly", -- Use the nightly branch for the latest features and fixes

	opts = {
		section_anchor = "header_half",
		sections = {
			{
				title = sections.files,
				items = {

					{
						action = "Telescope find_files",
						label = "Find files",
						section = sections.files,
					},
					{
						action = "Telescope live_grep",
						label = "Live grep",
						section = sections.files,
					},
				},
			},
			{
				title = sections.config,
				items = {
					{
						action = "e $MYVIMRC",
						label = "Edit config",
					},
				},
			},
			{
				title = sections.plugins,
				items = {
					{ action = "Lazy", label = "Manage plugins" },
					{
						action = "Mason",
						label = "Manage LSPs and tools",
						section = sections.plugins,
					},
				},
			},
			{
				title = sections.exit,
				items = {
					{ action = "qa", label = "Quit Neovim" },
				},
			},
		},

		header = {
			" _   _            _   _ _           ",
			"| \\ | |          | | | (_)          ",
			"|  \\| | ___  ___ | | | |_ _ __ ___  ",
			"| . ` |/ _ \\/ _ \\| | | | | '_ ` _ \\ ",
			"| |\\  |  __/ (_) \\ \\_/ / | | | | | |",
			"\\_| \\_/\\___|\\___/ \\___/|_|_| |_| |_|",
		},

		footer_mt = 2,
		footer = "Welcome to Neovim! Happy coding!",

		-- You can also set a dynamic footer, for example to show a random quote from leo-alvarenga/quoth.nvim (https://github.com/leo-alvarenga/quoth.nvim)
		-- footer = function()
		--   local quote = require("quoth-nvim").get_random_quote()
		--   return { '"' .. quote.text .. '"', quote.author }
		-- end,
	},
}
