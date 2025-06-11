return {
	"aaronik/treewalker.nvim",
	cmd = "Treewalker",
	opts = {},
	keys = {
		{ "<C-Up", "<CMD>Treewalker Up<CR>", desc = "Node up", mode = { "n", "v" }, silent = true },
		{ "<C-Down>", "<CMD>Treewalker Down<CR>", desc = "Node down", mode = { "n", "v" }, silent = true },

		{ "<C-S-Right", "<CMD>Treewalker SwapRight<CR>", desc = "Swap Right", mode = "n", silent = true },
		{ "<C-S-Left>", "<CMD>Treewalker SwapLeft<CR>", desc = "Swap Left", mode = "n", silent = true },
	},
}
