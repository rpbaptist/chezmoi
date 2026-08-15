-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window("^(Bluetooth Devices)$", { no_screen_share = true, tag = "+floating-window" })

-- --- Steam Fixes ---
o.window({ class = "^(steam)$", title = "^(Steam)$" }, { float = false, tile = true })
o.window({ class = "^(steam)$", title = "^(Friends List|Settings|Properties)$" }, { float = true })

-- --- Game Fixes (Excluding Steam) ---
o.window({ xwayland = true }, { opacity = "1.0 override 1.0 override" })
o.window({ xwayland = true, class = "negative:^(steam)$" }, { fullscreen = true })
