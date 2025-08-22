return {
	"vieitesss/miniharp.nvim",
	event = "VeryLazy",
	opts = {
    autoload = false,
    autosave = false,
  },
	keys = {
		{
			"<leader>mm",
			function()
				require("miniharp").toggle_file()
			end,
			desc = "Mark file",
		},
		{
			"]m",
			function()
				require("miniharp").next()
			end,
			desc = "Next mark",
		},
		{
			"[m",
			function()
				require("miniharp").previous()
			end,
			desc = "Previous mrk",
		},
	},
}
