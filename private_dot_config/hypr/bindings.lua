-- Personal keybinding overrides, ported from the pre-Quattro bindings.conf.
-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Free up keys that Omarchy's defaults use, before rebinding them below.
-- Faithful port of the old unbind list -- some now free a key Quattro's
-- default reassigned to something else; keeping old muscle memory throughout.
hl.unbind("SUPER + O")
hl.unbind("SUPER + J")
hl.unbind("SUPER + F")
hl.unbind("SUPER + CTRL + C")
hl.unbind("SUPER + CTRL + N")
hl.unbind("SUPER + CTRL + T")
hl.unbind("SUPER + CTRL + F")
hl.unbind("SUPER + CTRL + B")
hl.unbind("SUPER + CTRL + E")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + SPACE") -- keep the top-bar toggle disabled
hl.unbind("SUPER + ALT + F")
hl.unbind("SUPER + S")
hl.unbind("SUPER + ALT + S")
hl.unbind("SUPER + C") -- keep universal copy inert
hl.unbind("SUPER + X") -- keep universal cut inert
hl.unbind("SUPER + V") -- keep universal paste inert
hl.unbind("SUPER + CTRL + V") -- Quattro's native clipboard-manager panel; SUPER + CTRL + H covers this instead, below
hl.unbind("SUPER + CTRL + H")
hl.unbind("SUPER + CTRL + SPACE")
-- resize windows
hl.unbind("SUPER + code:20")
hl.unbind("SUPER + code:21")
hl.unbind("SUPER + SHIFT + code:20")
hl.unbind("SUPER + SHIFT + code:21")
-- Mouse control
hl.unbind("SUPER + mouse:272")
hl.unbind("SUPER + mouse:273")
-- Quattro reassigned these to defaults that collide with the rebinds below
hl.unbind("SUPER + CTRL + D")   -- was "Display" toggle; Capture menu goes here instead
hl.unbind("SUPER + SHIFT + N")  -- was "Editor"; window-swap-left goes here instead
hl.unbind("SUPER + CTRL + ALT + D")  -- was default Calendar; moved to SUPER + D
-- Unbind F9 dictation push-to-talk (was: voxtype record start/stop)
hl.unbind("F9")

o.bind("SUPER + CTRL + D", "Capture menu", "omarchy-menu capture")
o.bind("SUPER + ALT + T", "Toggle light/dark theme", "omarchy-toggle-theme-mode")

o.bind("SUPER + CTRL + T", "Terminal", "uwsm app -- $TERMINAL")
o.bind("CTRL + SHIFT + ESCAPE", "Activity", { tui = "btop" })
o.bind("SUPER + CTRL + F", "File manager", "uwsm app -- pcmanfm")
o.bind("SUPER + CTRL + B", "Browser", "omarchy-launch-browser")

-- If your web app url contains #, type it as ## to prevent Hyprland treating it as a comment.
o.bind("SUPER + CTRL + C", "Calendar", 'omarchy-launch-webapp "https://app.hey.com/calendar/weeks/"')
o.bind("SUPER + CTRL + E", "Email", 'omarchy-launch-webapp "https://app.hey.com"')

-- Overwrite existing bindings, like putting Omarchy Menu on Super + Space
o.bind("SUPER + O", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + ALT + M", "Tiled full screen", "hyprctl dispatch fullscreenstate 0 2")
o.bind("SUPER + M", "Maximize window", hl.dsp.window.fullscreen({ mode = "maximized" }))

o.bind("SUPER + CTRL + H", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

o.bind("SUPER + F", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")

-- Control tiling
o.bind("SUPER + SHIFT + H", "Show hidden windows", hl.dsp.workspace.toggle_special())

-- Control scratchpad
o.bind("SUPER + ALT + H", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + H", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

o.bind("SUPER + CTRL + SPACE", "Omarchy menu", "omarchy-menu")

-- Move focus with vim keys (arrow keys handled by omarchy)
o.bind("SUPER + N", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + I", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + U", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + E", "Focus on below window", hl.dsp.focus({ direction = "d" }))

-- Move window with vim keys (arrow keys use omarchy swapwindow)
o.bind("SUPER + SHIFT + U", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + E", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + N", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + I", "Swap window right", hl.dsp.window.swap({ direction = "r" }))

-- Switch workspaces (1-10 via omarchy code:10-19)
o.bind("SUPER + bracketleft", "Previous workspace", hl.dsp.focus({ workspace = "-1" }))
o.bind("SUPER + bracketright", "Next workspace", hl.dsp.focus({ workspace = "+1" }))

-- Move window to workspace
o.bind("SUPER + ALT + bracketleft", "Move window to previous workspace", hl.dsp.window.move({ workspace = "-1" }))
o.bind("SUPER + ALT + bracketright", "Move window to next workspace", hl.dsp.window.move({ workspace = "+1" }))

-- Move active window silently to a workspace with mod + CTRL + SHIFT + [0-9]
for workspace = 1, 10 do
  local key = workspace == 10 and "0" or tostring(workspace)
  o.bind(
    "SUPER + CTRL + SHIFT + " .. key,
    "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace), follow = false })
  )
end

o.bind("SUPER + CTRL + ALT + N", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("SUPER + CTRL + ALT + I", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.bind("SUPER + CTRL + ALT + U", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.bind("SUPER + CTRL + ALT + E", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

o.bind("ALT + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("CTRL + ALT + mouse:272", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- Show calendar / toggle laptop display (eDP-1)
o.bind("SUPER + D", "Calendar", "omarchy-shell shell toggle omarchy.clock")
o.bind("SUPER + ALT + D", "Toggle laptop display", "omarchy-hyprland-monitor-internal toggle")

o.bind("mouse:275", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("mouse:276", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
