--- Ergoterm.nvim terminal provider for Claude Code.
-- @module terminal.ergoterm

local M = {}

local terminal = nil
local ergoterm = nil

--- Normalize focus parameter
--- @param focus boolean|nil
--- @return boolean
local function normalize_focus(focus)
	return focus or true
end

--- Builds ergoterm Terminal options
--- @param config table Terminal configuration (split_side, split_width_percentage, etc.)
--- @param env_table table Environment variables to set for the terminal process
--- @param cmd_string string Command to run in terminal
--- @param focus boolean|nil Whether to focus the terminal when opened (defaults to true)
--- @return table Ergoterm Terminal configuration
local function build_terminal_opts(config, env_table, cmd_string, focus)
	focus = normalize_focus(focus)

	local layout = config.split_side == "left" and "left" or "right"
	local width_percentage = string.format("%.0f%%", config.split_width_percentage * 100)
	local close_on_exit = config.auto_close or false

	return {
		name = "claude-code",
		cmd = cmd_string,
		layout = layout,
		start_in_insert = focus,
		auto_scroll = true,
		selectable = true,
		env = env_table,
		close_on_job_exit = close_on_exit,
		size = {
			right = width_percentage,
			left = width_percentage,
		},
	}
end

function M.is_available()
	local ergoterm_available, _ergoterm = pcall(require, "ergoterm.terminal")
	return ergoterm_available
end

function M.is_started()
	return terminal and terminal:is_started()
end

function M.setup()
	if not M.is_available() then
		vim.notify("Failed to load ergoterm.terminal", vim.log.levels.ERROR)
		return
	end
end

--- @param cmd_string string
--- @param env_table table
--- @param config table
--- @param focus boolean|nil
function M.open(cmd_string, env_table, config, focus)
	focus = normalize_focus(focus)

	if M.is_started() then
		return focus and terminal:focus()
	end

	-- Create new terminal
	local opts = build_terminal_opts(config, env_table, cmd_string, focus)
	terminal = require("ergoterm.terminal").Terminal:new(opts)

	terminal:open()
	if focus then
		terminal:focus()
	end
end

function M.close()
	if M.is_started() then
		terminal:close()
	end
end

--- Simple toggle: always show/hide terminal regardless of focus
--- @param cmd_string string
--- @param env_table table
--- @param config table
function M.simple_toggle(cmd_string, env_table, config)
	if M.is_started() then
		if terminal:is_open() then
			terminal:close()
		else
			terminal:focus()
		end
	else
		M.open(cmd_string, env_table, config, true)
	end
end

--- Smart focus toggle: switches to terminal if not focused, hides if currently focused
--- @param cmd_string string
--- @param env_table table
--- @param config table
function M.focus_toggle(cmd_string, env_table, config)
	if M.is_started() then
		if terminal:is_focused() then
			terminal:close()
		else
			terminal:focus()
		end
	else
		M.open(cmd_string, env_table, config, true)
	end
end

--- Legacy toggle function for backward compatibility (defaults to simple_toggle)
--- @param cmd_string string
--- @param env_table table
--- @param config table
function M.toggle(cmd_string, env_table, config)
	M.simple_toggle(cmd_string, env_table, config)
end

--- @return number|nil
function M.get_active_bufnr()
	if M.is_started() then
		-- ergoterm doesn't expose buffer directly, but we can try to get it
		-- from the terminal's internal state if available
		if terminal.buf and vim.api.nvim_buf_is_valid(terminal.buf) then
			return terminal.buf
		end
	end
	return nil
end

return M
