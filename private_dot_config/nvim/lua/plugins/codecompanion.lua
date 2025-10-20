return {
	"olimorris/codecompanion.nvim",
	lazy = true,
	dependencies = {
		"nvim-mini/mini.diff",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"saghen/blink.cmp",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown", "codecompanion" },
		},
	},
	opts = {
		strategies = {
			chat = {
				adapter = "claude_code",
				roles = {
					llm = "  Claude",
					user = "  Prompt",
				},
				slash_commands = {
					["buffer"] = {
						opts = {
							provider = "snacks",
						},
					},
					["fetch"] = {
						opts = {
							provider = "snacks",
						},
					},
					["file"] = {
						opts = {
							provider = "snacks",
						},
					},
					["help"] = {
						opts = {
							provider = "snacks",
						},
					},
					["symbols"] = {
						opts = {
							provider = "snacks",
						},
					},
				},
				keymaps = {
					completion = {
						modes = {
							i = "<C-.>",
						},
					},
					send = {
						modes = {
							n = "<C-s>",
						},
					},
				},
			},
			inline = { adapter = "anthropic" },
			agent = { adapter = "claude_code" },
		},
		display = {
			action_palette = {
				provider = "snacks",
			},
			chat = {
				window = {
					width = 0.28,
				},
				show_settings = true,
				start_in_insert_mode = true,
			},
			diff = {
				provider = "mini_diff",
			},
		},
		adapters = {
			-- copilot = function()
			-- 	return require("codecompanion.adapters").extend("copilot", {
			-- 		schema = {
			-- 			model = {
			-- 				default = "claude-3.7-sonnet",
			-- 			},
			-- 		},
			-- 	})
			-- end,
			http = {
				anthropic = function()
					return require("codecompanion.adapters").extend("anthropic", {
						env = {
							api_key = "cmd:cat $HOME/.local/anthropic",
						},
						schema = {
							model = {
								-- default = "claude-3-7-sonnet-20250219",
							},
						},
					})
				end,
			},
			acp = {
				anthropic = function()
					return require("codecompanion.adapters").extend("claude_code", {
						env = {
							api_key = "cmd:cat $HOME/.local/anthropic",
						},
						schema = {
							model = {
								-- default = "claude-3-7-sonnet-20250219",
							},
						},
					})
				end,
			},
		},
	},
	keys = {
		{ "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion actions", mode = { "n", "v" } },
		{ "<leader>ac", "<cmd>CodeCompanionChat<CR>", desc = "CodeCompanion chat", mode = { "n", "v" } },
		-- { "<leader>ai", "<cmd>CodeCompanion<CR>", desc = "CodeCompanion chat inline", mode = { "n", "v" } },
		{ "<leader>at", "<cmd>CodeCompanionChat Toggle<CR>", desc = "CodeCompanion chat toggle", mode = { "n", "v" } },
		{ "<leader>ae", "<cmd>CodeCompanionChat Add<CR>", desc = "CodeCompanion chat add", mode = { "n", "v" } },
	},
	init = function()
		vim.cmd([[cab cc CodeCompanion]])
	end,
}
