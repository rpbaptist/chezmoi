return {
	"folke/snacks.nvim",
	cmd = "Snacks",
	opts = {
		toggle = { enabled = true },
	},
	-- init = function()
	-- 	Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
	-- 	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
	-- 	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
	-- 	Snacks.toggle.diagnostics():map("<leader>ud")
	-- 	Snacks.toggle.line_number():map("<leader>ul")
	-- 	if vim.lsp.inlay_hint then
	-- 		Snacks.toggle.inlay_hints():map("<leader>uh")
	-- 	end
	-- end,
	keys = {
		{
			"<leader>uf",
			function()
				Snacks.toggle("format")
			end,
			desc = "Toggle Format",
		},
		{
			"<leader>us",
			function()
				Snacks.toggle.option("spell", { name = "Spelling" })
			end,
			desc = "Toggle Spelling",
		},
		{
			"<leader>uw",
			function()
				Snacks.toggle.option("wrap", { name = "Wrap" })
			end,
			desc = "Toggle Wrap",
		},
		{
			"<leader>uL",
			function()
				Snacks.toggle.option("relativenumber", { name = "Relative Number" })
			end,
			desc = "Toggle Relative Number",
		},
		{
			"<leader>ud",
			function()
				Snacks.toggle.diagnostics()
			end,
			desc = "Toggle Diagnostics",
		},
		{
			"<leader>ul",
			function()
				Snacks.toggle.line_number()
			end,
			desc = "Toggle Line Number",
		},
	},
}
