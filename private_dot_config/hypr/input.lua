-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- Only the deltas from Omarchy's default/hypr/input.lua: repeat_rate (40) and
-- scroll_factor (0.4) already match; the terminal scroll_touchpad window
-- rules for Alacritty/kitty/ghostty are already covered by the default.
hl.config({
  input = {
    kb_options = "compose:caps",
    repeat_delay = 600,

    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
    },
  },
})

hl.device({ name = "logitech-mx-ergo-1", sensitivity = -0.3 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
