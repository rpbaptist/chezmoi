return {
	"nanozuki/tabby.nvim",
	dependencies = {
		"nvim-mini/mini.nvim",
	},
	event = "VeryLazy",
	opts = {
		line = function(line)
			local theme = {
				fill = "TabLineFill",
				current_tab = "TabLineSel",
				tab = "TabLine",
				win = "TabLineWin",
			}
			return {
				line.tabs().foreach(function(tab)
					local hl = tab.is_current() and theme.current_tab or theme.tab
					local icon = tab.is_current() and " " or " "
					return {
						{
							line.sep("", hl, theme.fill),
							icon,
							line.sep(" ", hl, theme.win),
							hl = hl,
							margin = " ",
						},
						{
							tab.name(),
							line.sep("", theme.win, theme.fill),
							hl = theme.win,
							margin = " ",
						},
					}
				end),
				line.spacer(),
				hl = theme.fill,
			}
		end,
	},
}
