-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 3,
    no_focus_fallback = true,
  },

  decoration = {
    rounding = 4,
    rounding_power = 4.0,
  },

  layout = {
    single_window_aspect_ratio = { 4, 3 },
  },
})

-- Reference Omarchy's existing "easeOutQuint" curve by name; only define our
-- own via hl.curve() if reload complains it's missing.
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "easeOutQuint" })
