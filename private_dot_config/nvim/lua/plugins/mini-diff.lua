return {
	"echasnovski/mini.diff",
  event = "VeryLazy",
	opts = {
		view = {
			style = "sign",
			signs = {
				add = "+",
				change = "▪",
				delete = "",
			},
		},
	},
	keys = {
		{
			"<leader>gd",
			function()
				require("mini.diff").toggle_overlay()
			end,
			desc = "Toggle mini.diff overlay",
		},
	},
}

