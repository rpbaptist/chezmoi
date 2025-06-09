local M = {}

M.get_file_path = function(absolute)
	if absolute then
		return vim.fn.expand("%:p")
	else
		return vim.fn.expand("%:.")
	end
end

M.get_line_nr = function(path, line)
	if line then
		return path .. ":" .. vim.fn.line(".")
	else
		return path
	end
end

M.get = function(opts)
	opts = opts or {}
	local path = M.get_file_path(opts.absolute)
	return M.get_line_nr(path, opts.line)
end

M.copy = function(opts)
	opts = opts or {}
	local full_path = M.get(opts)
	vim.fn.setreg("+", full_path)
	vim.notify("Copied " .. full_path .. " to clipboard")
end

return M
