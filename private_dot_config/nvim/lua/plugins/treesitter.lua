return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		version = false,
		build = ":TSUpdate",
		keys = {
			{ "<c-space>", desc = "Increment Selection" },
			{ "<bs>", desc = "Decrement Selection", mode = "x" },
		},
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"eex",
				"elixir",
				"git_rebase",
				"gitattributes",
				"gitcommit",
				"gitignore",
				"heex",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
				"git_config",
			},
			highlight = { enable = true },
			indent = { enable = true },
			-- incremental_selection = {
			-- 	enable = true,
			-- 	keymaps = {
			-- 		init_selection = "<C-space>",
			-- 		node_incremental = "<C-space>",
			-- 		scope_incremental = false,
			-- 		node_decremental = "<bs>",
			-- 	},
			-- },
			-- textobjects = {
			-- 	move = {
			-- 		enable = true,
			-- 		goto_next_start = {
			-- 			["]f"] = "@function.outer",
			-- 			["]c"] = "@class.outer",
			-- 			["]a"] = "@parameter.inner",
			-- 		},
			-- 		goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
			-- 		goto_previous_start = {
			-- 			["[f"] = "@function.outer",
			-- 			["[c"] = "@class.outer",
			-- 			["[a"] = "@parameter.inner",
			-- 		},
			-- 		goto_previous_end = {
			-- 			["[F"] = "@function.outer",
			-- 			["[C"] = "@class.outer",
			-- 			["[A"] = "@parameter.inner",
			-- 		},
			-- 	},
			-- 	swap = {
			-- 		enable = false,
			-- 	},
			-- },
		},
		config = function(_, opts)
			local ts_utils = require("utils.treesitter")

			require("nvim-treesitter").setup(opts)

			ts_utils.install(opts.ensure_installed)

			vim.filetype.add({
				extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
				filename = {
					["vifmrc"] = "vim",
				},
				pattern = {
					[".*/kitty/.+%.conf"] = "kitty",
					["%.env%.[%w_.-]+"] = "sh",
				},
			})
			vim.treesitter.language.register("bash", "kitty")
			vim.treesitter.language.register("markdown", "livebook")

			-- highlights
			local parsersInstalled = require("nvim-treesitter.config").get_installed("parsers")
			for _, parser in pairs(parsersInstalled) do
				local filetypes = vim.treesitter.language.get_filetypes(parser)
				vim.api.nvim_create_autocmd({ "FileType" }, {
					pattern = filetypes,
					callback = function()
						vim.treesitter.start()
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end,
				})
			end

			require("nvim-treesitter").update()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			mode = "cursor",
			max_lines = 3,
		},
	},
}
