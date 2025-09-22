return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		event = { "BufReadPost", "BufNewFile" },
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
				event = { "BufReadPost", "BufNewFile" },
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

			vim.api.nvim_create_autocmd("FileType", { -- enable treesitter highlighting and indents
				group = vim.api.nvim_create_augroup("treesitter-config", { clear = true }),
				callback = function(ev)
					local filetype = ev.match
					local lang = vim.treesitter.language.get_lang(filetype)
					if vim.treesitter.language.add(lang) then
						vim.wo.foldmethod = "expr"
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						vim.treesitter.start()
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		opts = {},
		keys = function()
			local moves = {
				goto_next_start = {
					["]f"] = "@function.outer",
					["]c"] = "@class.outer",
					["]a"] = "@parameter.inner",
				},
				goto_next_end = {
					["]F"] = "@function.outer",
					["]C"] = "@class.outer",
					["]A"] = "@parameter.inner",
				},
				goto_previous_start = {
					["[f"] = "@function.outer",
					["[c"] = "@class.outer",
					["[a"] = "@parameter.inner",
				},
				goto_previous_end = {
					["[F"] = "@function.outer",
					["[C"] = "@class.outer",
					["[A"] = "@parameter.inner",
				},
			}
			local ret = {}
			for method, keymaps in pairs(moves) do
				for key, query in pairs(keymaps) do
					local desc = query:gsub("@", ""):gsub("%..*", "")
					desc = desc:sub(1, 1):upper() .. desc:sub(2)
					desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
					desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
					ret[#ret + 1] = {
						key,
						function()
							-- don't use treesitter if in diff mode and the key is one of the c/C keys
							if vim.wo.diff and key:find("[cC]") then
								return vim.cmd("normal! " .. key)
							end
							require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
						end,
						desc = desc,
						mode = { "n", "x", "o" },
						silent = true,
					}
				end
			end
			return ret
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
