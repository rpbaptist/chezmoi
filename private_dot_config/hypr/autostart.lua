-- Extra autostart processes.
o.launch_on_start("udiskie --no-automount --no-tray")
o.launch_on_start("env SSH_ASKPASS=/usr/lib/gcr-ssh-askpass SSH_ASKPASS_REQUIRE=force ssh-add " .. os.getenv("HOME") .. "/.ssh/richard_ed25519")

-- Remove gaps in workspace numbers when a workspace becomes empty, but not
-- when a window is moved: moving a window to an empty slot must keep it there.
-- A move that empties its old workspace also fires workspace.removed, so skip
-- removals for a moment after each move.
local moving = false

hl.on("window.move_to_workspace", function()
  moving = true
  hl.timer(function()
    moving = false
  end, { type = "oneshot", timeout = 250 })
end)

local function compact()
  hl.exec_cmd("hyprland-compact-workspaces")
end

hl.on("window.destroy", compact)
hl.on("workspace.removed", function()
  if not moving then
    compact()
  end
end)
