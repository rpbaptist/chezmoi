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
		local terms = require("ergoterm")

		local iex_tests = terms.Terminal:new({
			cmd = "iex -S mix",
			name = "IexTests",
			layout = "right",
			auto_list = false,
			bang_target = false,
			sticky = true,
			auto_scroll = true,
			start_in_insert = false,
			close_on_job_exit = true,
			size = { right = 80 },
			env = {
				MIX_ENV = "test",
			},
		})

		local ruby_tests = terms.Terminal:new({
			name = "RubyTests",
			layout = "right",
			auto_list = false,
			bang_target = false,
			sticky = true,
			auto_scroll = true,
			start_in_insert = false,
			close_on_job_exit = false,
			size = { right = 80 },
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
					local toggle = {
						ruby = function() ruby_tests:toggle() end,
						elixir = function() iex_tests:toggle() end,
					}
					local fn = toggle[vim.bo.filetype]
					if fn then fn() end
				end,
				desc = "Toggle test terminal",
			},
			{
				"<leader>tf",
				function()
					local file_path = vim.fn.expand("%")
					local run = {
						ruby = function()
							ruby_tests:send({ "rake test TEST=" .. file_path }, { action = "open" })
						end,
						elixir = function()
							iex_tests:start()
							iex_tests:send({ 'IexTests.test("' .. file_path .. '")' }, { action = "open" })
						end,
					}
					local fn = run[vim.bo.filetype]
					if fn then fn() end
				end,
				desc = "Test file",
			},
			{
				"<leader>tt",
				function()
					local file_path = vim.fn.expand("%")
					local line_number = vim.fn.line(".")
					local run = {
						elixir = function()
							iex_tests:start()
							iex_tests:send(
								{ 'IexTests.test("' .. file_path .. ":" .. line_number .. '")' },
								{ action = "open" }
							)
						end,
					}
					local fn = run[vim.bo.filetype]
					if fn then fn() end
				end,
				desc = "Test line",
			},
			{
				"<leader>twf",
				function()
					iex_tests:start()
					local file_path = vim.fn.expand("%")
					iex_tests:send({ 'IexTests.test_watch("' .. file_path .. '")' }, { action = "open" })
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
