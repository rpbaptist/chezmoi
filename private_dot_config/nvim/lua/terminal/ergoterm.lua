--- Ergoterm.nvim terminal provider for Claude Code.
-- @module terminal.ergoterm

--- @type TerminalProvider
local M = {}

local terminal = nil

--- @return boolean
local function is_available()
  local ergoterm_available, ergoterm = pcall(require, "ergoterm.terminal")
  return ergoterm_available and ergoterm and ergoterm.Terminal
end

--- Setup event handlers for terminal instance
--- @param term_instance table The ergoterm Terminal instance
--- @param config table Configuration options
local function setup_terminal_events(term_instance, config)
  -- Handle command completion/exit - only if auto_close is enabled
  if config.auto_close then
    -- Note: ergoterm doesn't have direct event handlers like Snacks,
    -- so we'll need to monitor the terminal state differently
    -- For now, we'll rely on the terminal's built-in cleanup mechanisms
    vim.notify("Ergoterm terminal created with auto_close enabled", vim.log.levels.DEBUG)
  end
end

--- Normalize focus parameter
--- @param focus boolean|nil
--- @return boolean
local function normalize_focus(focus)
  return focus ~= false
end

--- Builds ergoterm Terminal options
--- @param config table Terminal configuration (split_side, split_width_percentage, etc.)
--- @param env_table table Environment variables to set for the terminal process
--- @param cmd_string string Command to run in terminal
--- @param focus boolean|nil Whether to focus the terminal when opened (defaults to true)
--- @return table Ergoterm Terminal configuration
local function build_terminal_opts(config, env_table, cmd_string, focus)
  focus = normalize_focus(focus)

  -- Convert split_side to ergoterm layout string format
  local layout = config.split_side == "left" and "left" or "right"

  return {
    name = "claude-code",
    cmd = cmd_string,
    layout = layout,
    start_in_insert = focus,
    auto_scroll = true,
    selectable = true,
    env = env_table,
  }
end

function M.setup()
  -- No specific setup needed for ergoterm provider
end

--- @param cmd_string string
--- @param env_table table
--- @param config table
--- @param focus boolean|nil
function M.open(cmd_string, env_table, config, focus)
  if not is_available() then
    vim.notify("Ergoterm terminal provider selected but ergoterm.nvim not available.", vim.log.levels.ERROR)
    return
  end

  focus = normalize_focus(focus)

  if terminal and terminal:is_started() then
    -- Terminal exists
    if not terminal:is_open() then
      -- Terminal is hidden, show it
      terminal:open()
      if focus then
        terminal:focus()
      end
    else
      -- Terminal is already visible
      if focus then
        terminal:focus()
      end
    end
    return
  end

  -- Create new terminal
  local ergoterm_available, ergoterm = pcall(require, "ergoterm.terminal")
  if not ergoterm_available or not ergoterm or not ergoterm.Terminal then
    vim.notify("Failed to load ergoterm.terminal", vim.log.levels.ERROR)
    return
  end
  
  local opts = build_terminal_opts(config, env_table, cmd_string, focus)
  terminal = ergoterm.Terminal:new(opts)

  if terminal then
    setup_terminal_events(terminal, config)
    -- Start and open the terminal
    terminal:start()
    terminal:open()
    if focus then
      terminal:focus()
    end
  else
    local error_msg = string.format("Failed to create ergoterm Terminal with cmd='%s'", cmd_string)
    vim.notify(error_msg, vim.log.levels.ERROR)
  end
end

function M.close()
  if not is_available() then
    return
  end
  if terminal and terminal:is_started() then
    terminal:close()
  end
end

--- Simple toggle: always show/hide terminal regardless of focus
--- @param cmd_string string
--- @param env_table table
--- @param config table
function M.simple_toggle(cmd_string, env_table, config)
  if not is_available() then
    vim.notify("Ergoterm terminal provider selected but ergoterm.nvim not available.", vim.log.levels.ERROR)
    return
  end

  if terminal and terminal:is_started() then
    if terminal:is_open() then
      -- Terminal is visible, close it
      terminal:close()
    else
      -- Terminal exists but not visible, show it
      terminal:open()
      terminal:focus()
    end
  else
    -- No terminal exists, create new one
    M.open(cmd_string, env_table, config, true)
  end
end

--- Smart focus toggle: switches to terminal if not focused, hides if currently focused
--- @param cmd_string string
--- @param env_table table
--- @param config table
function M.focus_toggle(cmd_string, env_table, config)
  if not is_available() then
    vim.notify("Ergoterm terminal provider selected but ergoterm.nvim not available.", vim.log.levels.ERROR)
    return
  end

  if terminal and terminal:is_started() then
    if terminal:is_open() then
      -- Terminal is visible - check if focused
      if terminal:is_focused() then
        -- Currently focused, hide it
        terminal:close()
      else
        -- Not focused, focus it
        terminal:focus()
      end
    else
      -- Terminal exists but not visible, show and focus it
      terminal:open()
      terminal:focus()
    end
  else
    -- No terminal exists, create new one
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
  if terminal and terminal:is_started() then
    -- ergoterm doesn't expose buffer directly, but we can try to get it
    -- from the terminal's internal state if available
    if terminal.buf and vim.api.nvim_buf_is_valid(terminal.buf) then
      return terminal.buf
    end
  end
  return nil
end

--- @return boolean
function M.is_available()
  return is_available()
end

-- For testing purposes
--- @return table|nil
function M._get_terminal_for_test()
  return terminal
end

return M