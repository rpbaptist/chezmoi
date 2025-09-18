local M = {}

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
