local M = {}


M.have = function(what)
	what = what or vim.api.nvim_get_current_buf()
	what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]
	local lang = vim.treesitter.language.get_lang(what)
	return lang ~= nil and M.get_installed()[lang] ~= nil
end

M.install = function(parsers)
	local installed = require("nvim-treesitter.config").get_installed()
	local install = vim.iter(parsers)
		:filter(function(name)
			return not vim.tbl_contains(installed, name)
		end)
		:totable()

	if #install > 0 then
		require("nvim-treesitter").install(install)
	end
end

return M
