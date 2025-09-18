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
		config = function()
			require("nvim-treesitter").install({
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
			})

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

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter.setup", {}),
				callback = function(args)
					local buf = args.buf
					local filetype = args.match

					-- you need some mechanism to avoid running on buffers that do not
					-- correspond to a language (like oil.nvim buffers), this implementation
					-- checks if a parser exists for the current language
					local language = vim.treesitter.language.get_lang(filetype) or filetype
					if not vim.treesitter.language.add(language) then
						return
					end

					-- highlight
					vim.treesitter.start(buf, language)

					-- indent
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

					-- fold
          vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
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
