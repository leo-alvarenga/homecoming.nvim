return {
	filetype = "homecoming",
	buffer_name = "homecoming://Dashboard",
	cmd = {
		open = {
			cmd = "Homecoming",
			desc = "Open the Homecoming dashboard",
		},
		open_and_preserve_other = {
			cmd = "HomecomingOpenAndPreserveOther",
			desc = "Open the Homecoming dashboard, preserving other buffers",
		},
		close_curr_buf = {
			cmd = "HomecomingCloseCurrBuf",
			desc = "Close the current buffer. If it's the last buffer, open the Homecoming dashboard",
		},
	},
	hl = {
		namespace = "homecoming_dashboard",
		current_item = "HomecomingDashboardCurrItem",
		footer = "HomecomingDashboardFooter",
		header = "HomecomingDashboardHeader",
		item = "HomecomingDashboardItem",
		section = "HomecomingDashboardSection",
	},
}
