# homecoming.nvim

A dead-simple, customizable and cozy dashboard.

## Motivation

I always felt that the startup experience could be more welcoming and useful. Most dashboard plugins I tried were either packed with features I didn’t need or required confusing or overwhelming configuration just to look decent. I wanted something that felt right out of the box—clean, simple, and easy to tweak. That’s why I built this plugin: to give myself (and others) a place that makes starting up Neovim feel inviting and hassle-free... evoking the feeling of **coming home** to a familiar and cozy environment every time I open my editor.

## Features

- **No configuration required to get started**
- Easy setup and configuration
- Customizable dashboard sections
- No dependencies

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'leo-alvarenga/homecoming.nvim'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'leo-alvarenga/homecoming.nvim',
  branch = 'nightly', -- Optional: specify the nightly branch if you want to use the latest features
  opts = {}, -- No configuration is required to get started
}
```

## Usage

After installation, the dashboard will appear automatically when you start Neovim with no files specified.

### Configuration

You can customize the dashboard in your `init.lua` or `init.vim`:

```lua
require('homecoming-nvim').setup({
  -- Example options
  header = "Welcome to Neovim!",
})
```

This is the default configuration, with all available options.

```lua

--- @class homecoming-nvim.Opts
--- @field auto_start boolean? If true, the dashboard will automatically open when Neovim starts with no file arguments. Default is true
--- @field header_hl_group string? The name of the highlight group to be used for the header section. Default is "Title"
--- @field header_mb integer? How many lines should be added as margin after the header section. Default is 1
--- @field header string|string[]|(fun(): string[]|string) A function that returns a list of strings to be displayed as the dashboard header
--- @field section_anchor homecoming-nvim.ContentAnchor? Determines which component to use as the anchor for centering when the centered option is enabled. If 'header', the header will be used as the anchor for centering. If 'self' or not specified, the longest line among header, section titles, and item labels will be used as the anchor for centering. Default is 'header'
--- @field section_hl_group string? The name of the highlight group to be used for section titles. Default is "Delimiter"
--- @field section_gap integer? How many lines should be added as gap between sections. Default is 1
--- @field sections homecoming-nvim.Section[] A list of sections to be displayed on the dashboard, each with a title and a list of items
--- @field item_gap integer? How many lines should be added as gap between items. Default is 0
--- @field item_hl_group string? The name of the highlight group to be used for items. Default is "Comment"
--- @field item_selected_hl_group string? The name of the highlight group to be used of the currently selected item. Default is "Normal"
--- @field item_prefix_char string? A string to prefix each item label with, default is ""
--- @field item_indent integer? How many spaces to indent each item label (including the len of item_prefix_char), default is 2
--- @field footer_anchor homecoming-nvim.ContentAnchor? Determines which component to use as the anchor for centering when the centered option is enabled. If 'header', the header will be used as the anchor for centering. If 'self' or not specified, the longest line among header, section titles, and item labels will be used as the anchor for centering. Default is 'self'
--- @field footer_hl_group string? The name of the highlight group to be used for the footer. Default is "ErrorMsg"
--- @field footer_mt integer? How many lines should be added as margin before the footer section. Default is 0
--- @field footer_mb integer? How many lines should be added as margin after the footer section. Default is 0
--- @field footer string|string[]|(fun(): string[]|string) A function that returns a list of strings to be displayed as the dashboard footer

--- @type homecoming-nvim.Opts
local opts = {
	auto_start = true,

	header_hl_group = "Title",
	header_mb = 1,
	header = function()
		return {
			"Welcome",
		}
	end,

	item_gap = 0,
	item_hl_group = "Comment",
	item_selected_hl_group = "Normal",
	item_indent = 2,
	item_prefix_char = "",

	section_anchor = "header",
	section_gap = 1,
	section_hl_group = "Delimiter",
	sections = {
		{
			title = "Actions",
			items = {
				{
					label = "New file",
					action = function()
						vim.cmd("enew")
					end,
				},
				{
					label = "Quit",
					action = function()
						vim.cmd("qa")
					end,
				},
			},
		},
		{
			title = "Resources",
			items = {
				{
					label = "Open config",
					action = function()
						vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
					end,
				},
			},
		},
	},

	footer_anchor = "self",
	footer_hl_group = "ErrorMsg",
	footer_mt = 2,
	footer_mb = 0,
	footer = function()
		return {
			"Have a productive session",
			"Neovim version: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
		}
	end,
}
```

## License

This project is licensed under the GPLv3 License. See the [LICENSE](LICENSE) file for details.
