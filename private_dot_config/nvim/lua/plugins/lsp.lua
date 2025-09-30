return {
	{
		"mason-org/mason.nvim",
		lazy = true,
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonLog", "MasonUpdate", "MasonUninstallAll" },
		opts = {
			ensure_installed = {
				"stylua",
				"shfmt",
				"markdownlint-cli2",
				"markdown-toc",
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = "VeryLazy",
		opts = {
			ensure_installed = vim.g.language_servers,
		},
		dependencies = {
			"neovim/nvim-lspconfig",
		},
	},
	{ "neovim/nvim-lspconfig" },
}
