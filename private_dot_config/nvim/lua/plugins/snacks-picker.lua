return {
	"folke/snacks.nvim",
	dependencies = {
		"xvzc/chezmoi.nvim",
	},
	lazy = false,
	opts = {
		explorer = { enabled = true },
		picker = {
			win = {
				input = {
					keys = {
						["<a-s>"] = { "flash", mode = { "n", "i" } },
						["s"] = { "flash" },
					},
				},
			},
			formatters = {
				file = {
					truncate = 150,
				},
			},
			actions = {
				flash = function(picker)
					require("flash").jump({
						pattern = "^",
						label = { after = { 0, 0 } },
						search = {
							mode = "search",
							exclude = {
								function(win)
									return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
								end,
							},
						},
						action = function(match)
							local idx = picker.list:row2idx(match.pos[1])
							picker.list:_move(idx, true, true)
						end,
					})
				end,
			},
			sources = {
				explorer = {
					-- auto_close = true,
					jump = { close = true },
					layout = {
						preset = function()
							return vim.o.columns >= 120 and "default" or "vertical"
						end,
						preview = true,
					},
					win = {
						list = {
							keys = {
								["<BS>"] = "explorer_up",
								["<Right>"] = "confirm",
								["<Left>"] = "explorer_close", -- close directory
								["a"] = "explorer_add",
								["d"] = "explorer_del",
								["r"] = "explorer_rename",
								["c"] = "explorer_copy",
								["m"] = "explorer_move",
								["P"] = "toggle_preview",
								["y"] = { "explorer_yank", mode = { "n", "x" } },
								["p"] = "explorer_paste",
								["u"] = "explorer_update",
								["<c-c>"] = "tcd",
								["<leader>/"] = "picker_grep",
								["<c-t>"] = "terminal",
								["."] = "explorer_focus",
								["I"] = "toggle_ignored",
								["H"] = "toggle_hidden",
								["Z"] = "explorer_close_all",
								["]g"] = "explorer_git_next",
								["[g"] = "explorer_git_prev",
								["]d"] = "explorer_diagnostic_next",
								["[d"] = "explorer_diagnostic_prev",
								["]w"] = "explorer_warn_next",
								["[w"] = "explorer_warn_prev",
								["]e"] = "explorer_error_next",
								["[e"] = "explorer_error_prev",
							},
						},
					},
				},
			},
		},
	},
	keys = {
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fE",
			function()
				Snacks.explorer({ layout = { preset = "sidebar", preview = false } })
			end,
			desc = "Find Files",
		},
		{
			"<leader>fe",
			function()
				Snacks.explorer()
			end,
			desc = "Find Files",
		},
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>bl",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep (Root Dir)",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader><space>",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files (Root Dir)",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>D",
			function()
				Snacks.picker.spelling()
			end,
			desc = "Spell suggestions",
		},
		-- find
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fB",
			function()
				Snacks.picker.buffers({ hidden = true, nofile = true })
			end,
			desc = "Buffers (all)",
		},
		{
			"<leader>fc",
			function()
				local opts = require("utils.chezmoi-snacks-picker").picker_opts(".config/nvim/")
				Snacks.picker.pick(opts)
			end,
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Find Files (git-files)",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent",
		},
		{
			"<leader>fR",
			function()
				Snacks.picker.recent({ filter = { cwd = true } })
			end,
			desc = "Recent (cwd)",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},
		-- git
		{
			"<leader>gb",
			function()
				Snacks.picker.git_log_line()
			end,
			desc = "Git Blame Line",
		},
		{
			"<leader>gf",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git file status",
		},
		{
			"<leader>gh",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git hunks",
		},
		{
			"<leader>gS",
			function()
				Snacks.picker.git_stash()
			end,
			desc = "Git Stash",
		},
		-- Grep
		{
			"<leader>sb",
			function()
				Snacks.picker.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sB",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "Grep Open Buffers",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker.lazy()
			end,
			desc = "Search for Plugin Spec",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Visual selection or word (Root Dir)",
			mode = { "n", "x" },
		},
		{
			'<leader>s"',
			function()
				Snacks.picker.registers()
			end,
			desc = "Registers",
		},
		{
			"<leader>s/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search History",
		},
		{
			"<leader>sa",
			function()
				Snacks.picker.autocmds()
			end,
			desc = "Autocmds",
		},
		{
			"<leader>sc",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>sC",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>sh",
			function()
				Snacks.picker.help()
			end,
			desc = "Help Pages",
		},
		{
			"<leader>sH",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Highlights",
		},
		{
			"<leader>si",
			function()
				Snacks.picker.icons()
			end,
			desc = "Icons",
		},
		{
			"<leader>sj",
			function()
				Snacks.picker.jumps()
			end,
			desc = "Jumps",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.loclist()
			end,
			desc = "Location List",
		},
		{
			"<leader>sM",
			function()
				Snacks.picker.man()
			end,
			desc = "Man Pages",
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.marks()
			end,
			desc = "Marks",
		},
		{
			"<leader>sR",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>su",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undotree",
		},
		-- ui
		{
			"<leader>uC",
			function()
				Snacks.picker.colorschemes()
			end,
			desc = "Colorschemes",
		},
		{
			"<leader>sz",
			function()
				local opts = require("utils.chezmoi-snacks-picker").picker_opts()
				Snacks.picker.pick(opts)
			end,
			desc = "Chezmoi",
		},
	},
}
