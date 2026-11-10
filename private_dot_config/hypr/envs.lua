-- Extra env variables. default/hypr/envs.lua already sets XCURSOR_SIZE=24,
-- HYPRCURSOR_SIZE=24, and all the Wayland/QT/Electron platform vars.
local paths = require("default.hypr.paths")

hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/gcr/ssh")
hl.env("XCURSOR_SIZE", "34")
hl.env("HYPRCURSOR_SIZE", "34")

-- Cursor theme contrasts with the mode: gruvbox-light cursor in dark mode,
-- gruvbox-dark cursor in light mode. Derived from current theme state
-- instead of hardcoded. A hardcoded default here would get
-- reverted by a `chezmoi apply` undoing whatever the theme-set hook last
-- set live (omarchy/hooks/executable_theme-set), and would start wrong on
-- a fresh install until the first manual theme toggle.
local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

local is_light = file_exists(paths.state_home .. "/omarchy/current/theme/light.mode")

local cursor_theme = is_light and "gruvbox-dark" or "gruvbox-light"

hl.env("XCURSOR_THEME", cursor_theme)
hl.env("HYPRCURSOR_THEME", cursor_theme)
