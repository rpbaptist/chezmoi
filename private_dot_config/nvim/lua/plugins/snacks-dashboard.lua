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
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{ icon = " ", key = "g", desc = "Git status", action = ":Fugit2" },
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function()
							local results = require("chezmoi.commands").list({
								args = {
									"--path-style",
									"absolute",
									"--include",
									"files",
									"--exclude",
									"externals",
								},
							})
							local items = {}

							for _, czFile in ipairs(results) do
								if string.find(czFile, ".config/nvim/") then
									table.insert(items, {
										text = czFile,
										file = czFile,
									})
								end
							end

							---@type snacks.picker.Config
							local opts = {
								items = items,
								confirm = function(picker, item)
									picker:close()
									require("chezmoi.commands").edit({
										targets = { item.text },
										args = { "--watch" },
									})
								end,
							}
							Snacks.picker.pick(opts)
						end,
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
	},
}
