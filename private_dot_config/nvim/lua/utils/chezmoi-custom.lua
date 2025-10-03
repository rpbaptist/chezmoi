local M = {}

M.list_config_files = function(filter)
	local results = require("chezmoi.commands").list({
		args = {
			"--path-style",
			"absolute",
			"--include",
			"files",
			"--exclude",
			"externals",
		},
	})
	local items = {}

	for _, czFile in ipairs(results) do
		if not filter or string.find(czFile, filter) then
			table.insert(items, {
				text = czFile,
				file = czFile,
			})
		end
	end

	return items
end

M.picker_opts = function(filter)
	local items = M.list_config_files(filter)

	return {
		items = items,
		confirm = function(picker, item)
			picker:close()
			require("chezmoi.commands").edit({
				targets = { item.text },
				args = { "--watch", "--apply" },
			})
		end,
	}
end

return M
