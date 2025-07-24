return {
	"waiting-for-dev/ergoterm.nvim",
	event = "VeryLazy",
	opts = {},
	keys = function()
		local terms = require("ergoterm.terminal")

		local iex_tests = terms.Terminal:new({
			cmd = "iex -S mix",
			name = "IexTests",
			layout = "right",
			selectable = false,
			env = {
				MIX_ENV = "test",
			},
		})

		return {
			{
				"<leader>tg",
				function()
					iex_tests.toggle()
				end,
			},
			{
				"<leader>tf",
				function()
					iex_tests.start()
					local file_path = vim.fn.expand("%")
					iex_tests:send({ 'IexTests.test("' .. file_path .. '")' }, { action = "visible" })
				end,
			},
			{
				"<leader>tt",
				function()
					iex_tests.start()
					local file_path = vim.fn.expand("%")
					local line_number = vim.fn.line(".")
					iex_tests:send(
						{ 'IexTests.test("' .. file_path .. ":" .. line_number .. '")' },
						{ action = "visible" }
					)
				end,
			},
			{
				"<leader>twf",
				function()
					iex_tests.start()
					local file_path = vim.fn.expand("%")
					iex_tests:send({ 'IexTests.test_watch("' .. file_path .. '")' }, { action = "visible" })
				end,
			},
			{
				"<leader>twt",
				function()
					iex_tests.start()
					local file_path = vim.fn.expand("%")
					local line_number = vim.fn.line(".")
					iex_tests:send(
						{ 'IexTests.test_watch("' .. file_path .. ":" .. line_number .. '")' },
						{ action = "visible" }
					)
				end,
			},
			{
				"<leader>tws",
				function()
					iex_tests.start()
					iex_tests:send({ "IexTests.stop_watch()" }, { action = "hidden" })
				end,
			},
		}
	end,
}
