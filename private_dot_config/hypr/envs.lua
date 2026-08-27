-- Extra env variables. default/hypr/envs.lua already sets XCURSOR_SIZE=24,
-- HYPRCURSOR_SIZE=24, and all the Wayland/QT/Electron platform vars.
hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")
hl.env("XCURSOR_THEME", "gruvbox-dark")
hl.env("XCURSOR_SIZE", "34")
hl.env("HYPRCURSOR_THEME", "gruvbox-dark")
hl.env("HYPRCURSOR_SIZE", "34")
