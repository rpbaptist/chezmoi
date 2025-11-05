return {
	"SmiteshP/nvim-navic",
	event = "VeryLazy",
	opts = function()
		return {
			depth_limit_indicator = "…",
			separator = "  ",
			highlight = true,
			depth_limit = 0,
			icons = vim.g.custom_icons.kinds,
			lazy_update_context = true,
		}
	end,
}
