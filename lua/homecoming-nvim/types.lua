--- @meta

--- @class homecoming-nvim.Item
--- @field label string The text to be displayed for the item in the dashboard
--- @field action string|function? The VimCMD or function to be executed when the item is selected

--- @class homecoming-nvim.Section
--- @field title string? The title of the section, displayed above the list of items
--- @field items homecoming-nvim.Item[] A list of items in the section, each with a label and an action function to execute when selected

--- @alias homecoming-nvim.ContentAnchor
--- | 'header'
--- | 'header_half'
--- | 'self'

--- @class homecoming-nvim.Opts
--- @field auto_start boolean? If true, the dashboard will automatically open when Neovim starts with no file arguments. Default is true
--- @field header_mb integer? How many lines should be added as margin after the header section. Default is 1
--- @field header string|string[]|(fun(): string[]|string) A function that returns a list of strings to be displayed as the dashboard header
--- @field section_anchor homecoming-nvim.ContentAnchor? Determines which component to use as the anchor for centering when the centered option is enabled. If 'header', the header will be used as the anchor for centering. If 'self' or not specified, the longest line among header, section titles, and item labels will be used as the anchor for centering. Default is 'header'
--- @field section_gap integer? How many lines should be added as gap between sections. Default is 1
--- @field sections homecoming-nvim.Section[] A list of sections to be displayed on the dashboard, each with a title and a list of items
--- @field item_gap integer? How many lines should be added as gap between items. Default is 0
--- @field item_prefix_char string? A string to prefix each item label with, default is ""
--- @field item_indent integer? How many spaces to indent each item label (including the len of item_prefix_char), default is 2
--- @field footer_anchor homecoming-nvim.ContentAnchor? Determines which component to use as the anchor for centering when the centered option is enabled. If 'header', the header will be used as the anchor for centering. If 'self' or not specified, the longest line among header, section titles, and item labels will be used as the anchor for centering. Default is 'self'
--- @field footer_mt integer? How many lines should be added as margin before the footer section. Default is 0
--- @field footer_mb integer? How many lines should be added as margin after the footer section. Default is 0
--- @field footer string|string[]|(fun(): string[]|string) A function that returns a list of strings to be displayed as the dashboard footer

--- @class homecoming-nvim.LineInfo
--- @field action string|function The VimCMD or function to be executed when the line is selected
--- @field len integer The length of the label text for the item on this line, used for calculating highlight ranges
--- @field line integer The line number in the dashboard buffer where this item is located, used for navigation and actions
--- @field start integer The starting column number for the label text of the item on this line, used for calculating highlight ranges

--- @class homecoming-nvim.LineHlRange
--- @field line integer The line number in the dashboard buffer where the highlight should be applied, used for navigation and actions
--- @field start_col integer The starting column number for the highlight range, used for calculating highlight ranges
--- @field end_col integer The ending column number for the highlight range, used for calculating highlight ranges

--- @class homecoming-nvim.DashboardState
--- @field buf integer|nil Buffer handle for the dashboard buffer
--- @field win integer|nil Window handle for the dashboard buffer
--- @field curr_item integer Current curr_item position (1-based index into the list of items)
--- @field highlight_ns integer|nil Namespace handle for curr_item highlighting
--- @field lines homecoming-nvim.LineInfo[] Cache of all lines in the dashboard, used for rendering and refreshing the buffer

return {}
