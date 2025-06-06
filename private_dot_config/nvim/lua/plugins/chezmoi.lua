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
}
