-- Extra autostart processes.
o.launch_on_start("bash -c 'SSH_ASKPASS=~/.local/bin/ssh-askpass-keyring SSH_ASKPASS_REQUIRE=prefer ssh-add ~/.ssh/richard_ed25519'")
o.launch_on_start("udiskie --tray")
