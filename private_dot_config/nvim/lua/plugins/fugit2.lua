return {
	"SuperBo/fugit2.nvim",
	lazy = true,
	dependencies = {
		{ "rpbaptist/nui.nvim", branch = "fix-invalid-window-id" },
		"nvim-lua/plenary.nvim",
	},
	cmd = { "Fugit2", "Fugit2Diff", "Fugit2Graph" },
	opts = {
		libgit2_path = "libgit2.so.1.7",
		show_patch = true,
	},
	keys = {
		{ "<leader>gs", "<cmd>Fugit2<cr>", desc = "Git status" },
	},
}
