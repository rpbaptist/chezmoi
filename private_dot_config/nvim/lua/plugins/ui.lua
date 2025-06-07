return {
	{
		"Tummetott/reticle.nvim",
		event = "VeryLazy",
		opts = {
			always_highlight_number = true,
		},
	},
	{
		"tzachar/highlight-undo.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{ "MunifTanjim/nui.nvim" },
	{
		"TungstnBallon/conflict.nvim",
		keys = {
			{ "]g", ":lua ConflictJumpToNext<cr>", desc = "Next conflict" },
			{ "[g", ":lua ConflictJumpToPrev<cr>", desc = "Previous conflict" },
			{ "<leader>gc", ":lua ConflictResolveAroundCursor<cr>", desc = "Resolve conflict" },
		},
	},
	{ "nacro90/numb.nvim", opts = {} },
}
