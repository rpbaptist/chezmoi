return {
	"waiting-for-dev/ergoterm.nvim",
	event = "VeryLazy",
	opts = {
		picker = {
			picker = "vim-ui-select",
		},
		size = {
			right = 100,
			below = 5,
		},
	},
	keys = function()
		local terms = require("ergoterm.terminal")

		local iex_tests = terms.Terminal:new({
			cmd = "iex -S mix",
			name = "IexTests",
			layout = "right",
			dir = "git_dir",
			start_in_insert = false,
			close_on_job_exit = false,
			size = { right = 80 },
			env = {
				MIX_ENV = "test",
			},
		})

		local quick_term = terms.Terminal:new({
			name = "QuickTerm",
			layout = "below",
			size = { below = 15 },
		})

		return {
			{
				"<leader>tl",
				"<CMD>TermSelect<CR>",
				desc = "List terminals",
			},
			{
				"<leader>tg",
				function()
					iex_tests:toggle()
				end,
				desc = "Toggle IexTests",
			},
			{
				"<leader>tf",
				function()
					iex_tests:start()
					local file_path = vim.fn.expand("%")
					iex_tests:send({ 'IexTests.test("' .. file_path .. '")' }, { action = "open" })
				end,
				desc = "Test file",
			},
			{
				"<leader>tt",
				function()
					iex_tests:start()
					local file_path = vim.fn.expand("%")
					local line_number = vim.fn.line(".")
					iex_tests:send(
						{ 'IexTests.test("' .. file_path .. ":" .. line_number .. '")' },
						{ action = "visible" }
					)
				end,
				desc = "Test line",
			},
			{
				"<leader>twf",
				function()
					iex_tests:start()
					local file_path = vim.fn.expand("%")
					iex_tests:send({ 'IexTests.test_watch("' .. file_path .. '")' }, { action = "visible" })
				end,
				desc = "Watch test file",
			},
			{
				"<leader>twt",
				function()
					iex_tests:start()
					local file_path = vim.fn.expand("%")
					local line_number = vim.fn.line(".")
					iex_tests:send(
						{ 'IexTests.test_watch("' .. file_path .. ":" .. line_number .. '")' },
						{ action = "visible" }
					)
				end,
				desc = "Watch test on line",
			},
			{
				"<leader>tws",
				function()
					iex_tests:start()
					iex_tests:send({ "IexTests.stop_watch()" }, { action = "hidden" })
				end,
				desc = "Stop test watch",
			},
			{
				"<C-/>",
				function()
					quick_term:toggle()
				end,
				desc = "Terminal float",
				mode = { "n", "i", "x", "t" },
			},
		}
	end,
}
