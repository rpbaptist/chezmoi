return {
	"folke/snacks.nvim",
	cmd = "Snacks",
	opts = {
		bigfile = { enabled = true },
		quickfile = { enabled = true },
		input = { enabled = true },
		indent = {
			indent = {
				hl = "GruvboxBg1",
			},
			scope = {
				only_current = true,
				hl = "GruvboxBg3",
			},
		},
		notifier = {
			timeout = 5000,
			style = "compact",
			styles = {
				notification = {
					wo = {
						winblend = 5,
						wrap = true,
						conceallevel = 2,
						colorcolumn = "",
					},
				},
			},
		},
		scratch = {
			styles = {
				height = 50,
			},
		},
		scope = { enabled = true },
		scroll = {
			animate = {
				duration = { step = 15, total = 160 },
			},
		},
		statuscolumn = { enabled = true },
		words = { enabled = true },
		terminal = { enabled = false },
	},
	keys = {
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"<leader>gY",
			function()
				Snacks.gitbrowse({
					open = function(url)
						vim.fn.setreg("+", url)
					end,
					notify = true,
				})
			end,
			desc = "Git Browse (copy)",
		},
		{
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git Browse (open)",
		},
		{
			"<leader>fD",
			function()
				local path = vim.fn.expand("%:.")
				vim.cmd(":! rm %")
				Snacks.bufdelete()
				vim.notify("Deleted " .. path)
			end,
			desc = "Delete file",
		},
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete Buffer",
		},
		{
			"<leader>bo",
			function()
				Snacks.bufdelete.other()
			end,
			desc = "Delete Other Buffers",
		},
	},
}
