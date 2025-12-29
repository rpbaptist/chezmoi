return {
	"folke/snacks.nvim",
	dependencies = {
		"xvzc/chezmoi.nvim",
	},
	cmd = "Snacks",
	lazy = false,
	opts = {
		dashboard = {
			preset = {
				pick = "fzf-lua",
				header = [[
        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
				keys = {
					{ icon = " ", key = "/", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
					{ icon = "󰱽 ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{ icon = " ", key = "g", desc = "Git Status", action = ":Fugit2" },
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function()
							local opts = require("utils.chezmoi-custom").picker_opts(".config/nvim/")
							Snacks.picker.pick(opts)
						end,
					},
					{
						icon = "󱊍 ",
						key = "m",
						desc = "Mason",
						action = ":lua Mason",
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
	},
}
