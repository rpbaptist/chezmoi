-- Extra autostart processes.
o.launch_on_start("udiskie --no-automount --no-tray")
o.launch_on_start("env SSH_ASKPASS=/usr/lib/gcr-ssh-askpass SSH_ASKPASS_REQUIRE=force ssh-add " .. os.getenv("HOME") .. "/.ssh/richard_ed25519")
