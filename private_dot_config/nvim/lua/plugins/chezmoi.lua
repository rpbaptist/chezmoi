return {
	"xvzc/chezmoi.nvim",
	cmd = { "ChezmoiEdit" },
	opts = {
		edit = {
			watch = false,
			force = false,
		},
		notification = {
			on_open = true,
			on_apply = true,
			on_watch = false,
		},
	},
	keys = {
		{
			"<leader>sz",
			pick_chezmoi,
			desc = "Chezmoi",
		},
	},
}
