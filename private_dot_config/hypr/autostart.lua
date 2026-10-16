-- Extra autostart processes.
o.launch_on_start("udiskie --no-automount --no-tray")
o.launch_on_start("env SSH_ASKPASS=/usr/lib/gcr-ssh-askpass SSH_ASKPASS_REQUIRE=force ssh-add " .. os.getenv("HOME") .. "/.ssh/richard_ed25519")

-- Remove gaps in workspace numbers when a workspace becomes empty.
for _, event in ipairs({ "window.destroy", "window.move_to_workspace", "workspace.removed" }) do
  hl.on(event, function()
    hl.exec_cmd("hyprland-compact-workspaces")
  end)
end
