local M = {}

-- Function to swap parameters
function M.swap_parameters(direction)
	local ts_utils = require("nvim-treesitter.ts_utils")
	local current_node = ts_utils.get_node_at_cursor()
	if current_node then
		local adjacent_node = nil

		if direction == "next" then
			adjacent_node = ts_utils.get_next_node(current_node, false, false)
		else
			adjacent_node = ts_utils.get_previous_node(current_node, false, false)
		end

		if adjacent_node then
			local bufnr = vim.api.nvim_get_current_buf()
			ts_utils.swap_nodes(current_node, adjacent_node, bufnr, true)
		end
	end
end

return M
