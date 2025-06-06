return {
	"folke/lazydev.nvim",
	ft = "lua",
	cmd = "LazyDev",
	event = "VeryLazy",
	opts = {
		library = {
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
		},
		sources = {
			-- add lazydev to your completion providers
			default = { "lazydev" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100, -- show at a higher priority than lsp
				},
			},
		},
	},
}
