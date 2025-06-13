return {
	{
		"mason-org/mason.nvim",
    lazy = true,
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonLog", "MasonUpdate", "MasonUninstallAll" },
		keys = { { "<leader>mu", "<cmd>Mason<cr>", desc = "Mason" } },
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
			ensure_installed = {
				"elixirls",
				"lua_ls",
				"marksman",
        "yamlls"
			},
		},
		dependencies = {
			"neovim/nvim-lspconfig",
		},
	},
	{ "neovim/nvim-lspconfig" },
}
