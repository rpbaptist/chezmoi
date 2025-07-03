return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		--[[ things you want to change go here]]
	},
	keys = {
		{
			"<leader>tE",
			function()
				require("toggleterm").exec("MIX_ENV=test iex -s mix", { direction = "vertical" })
			end,
			desc = "Start IEX test",
		},
	},
}

-- function TestCurrentFile()
-- 	local current_file = vim.fn.expand("%:p")
-- 	local cmd = 'IexTests.test("' .. current_file .. '")'
-- 	Snacks.terminal.get(cmd)
-- end
--
-- function TestCurrentLine()
-- 	local current_file = file_path.get({ absolute = true, line = true })
-- 	local cmd = 'IexTests.test("' .. current_file .. '")'
-- 	Snacks.terminal.get(cmd)
-- end
--
-- function TestCurrentDirectory()
-- 	local file_dir = vim.fn.expand("%:p:h")
-- 	local cmd = 'IexTests.test("' .. file_dir .. '")'
-- 	Snacks.terminal.get(cmd)
-- end
--
-- function WatchCurrentFile()
-- 	local current_file = vim.fn.expand("%:p")
-- 	local cmd = 'IexTests.test_watch("' .. current_file .. '")'
-- 	Snacks.terminal.get(cmd)
-- end
--
-- function StopWatchingCurrentFile()
-- 	Snacks.terminal.get("IexTests.stop_watch()")
-- end

-- set("n", "<leader>tt", ":lua TestCurrentFile()<CR>", { desc = "Test current file" })
-- set("n", "<leader>tl", ":lua TestCurrentLine()<CR>", { desc = "Test current line" })
-- set("n", "<leader>td", ":lua TestCurrentDirectory()<CR>", { desc = "Test current file directory" })
-- set("n", "<leader>tww", ":lua WatchCurrentFile()<CR>", { desc = "Watch current file" })
-- set("n", "<leader>tws", ":lua StopWatchingCurrentFile()<CR>", { desc = "Stop watching current file" })
--

