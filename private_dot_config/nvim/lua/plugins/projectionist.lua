return {
	"tpope/vim-projectionist",
	lazy = false,
	cmd = {
		"A",
		"AS",
		"AT",
		"AV",
	},
	keys = {
		{ "<leader>tj", group = "Jump to test file" },
		{ "<leader>tjj", "<cmd>A<cr>", desc = "Open file in current window" },
		{ "<leader>tje", "<cmd>AS<cr>", desc = "Open test file in hsplit" },
		{ "<leader>tji", "<cmd>AV<cr>", desc = "Open test file in vsplit" },
		{ "<leader>tj<Tab>", "<cmd>AT<cr>", desc = "Open test file in tab" },
	},
}
