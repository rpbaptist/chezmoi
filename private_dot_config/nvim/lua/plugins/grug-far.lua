return {
	"MagicDuck/grug-far.nvim",
  lazy = true,
	opts = { headerMaxWidth = 80 },
	cmd = "GrugFar",
	keys = {
		{
			"<leader>sr",
			function()
				require("grug-far").open({
					transient = true,
					prefills = {
						paths = vim.fn.expand("%"),
						search = vim.fn.expand("<cword>"),
					},
				})
			end,
			mode = { "n", "v" },
			desc = "Search and replace",
		},
	},
}
