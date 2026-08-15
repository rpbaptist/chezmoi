# Migrate chezmoi config after Omarchy → Omarchy Quattro upgrade

## Context

This machine was upgraded from Omarchy to Omarchy Quattro (4.0.0) today (2026-08-15, upgrade run `20260815095333`). The upgrade backed up every file it touched to `<name>.omarchy-upgrade-to-quattro.20260815095333.bak`, replaced the whole bar/launcher/notification/OSD stack (waybar, walker, mako, swayosd — packages, binaries and configs all gone) with a single system-managed `quickshell` instance (`quickshell -n -p /usr/share/omarchy/shell`, package `quickshell-git`), and — this is the load-bearing discovery of this investigation — **switched Hyprland itself from `.conf` to `.lua` configuration**. `hyprctl systeminfo` reports `configProvider: lua`; Hyprland 0.56.2 now boots from `~/.config/hypr/hyprland.lua`, which `require()`s `hypr.monitors`, `hypr.input`, `hypr.bindings`, `hypr.looknfeel`, `hypr.autostart`. It does **not** load `hyprland.conf` at all.

The upgrade generated five personal-override `.lua` stubs (`bindings.lua`, `looknfeel.lua`, `input.lua`, `autostart.lua`, `monitors.lua`) — all empty except for comments. None of your real customizations were ported. Meanwhile chezmoi still tracks the old `.conf` files (`bindings.conf` 4.1KB, `looknfeel.conf`, `input.conf`, `autostart.conf`, `envs.conf`, `windows.conf`, `hyprland.conf`) — these are now **dead**; restoring them via `chezmoi apply` would have no effect at all. This plan replaces "restore the `.conf` files" with "port their content into the new Lua files," confirmed against the user (scope-change approved).

Other confirmed findings from this session:
- `.local/share/omarchy` is now a symlink to the system package `/usr/share/omarchy` (Quattro installs Omarchy via pacman, not a git clone). chezmoi still tracks a real file at `private_dot_local/private_share/omarchy/bin/executable_omarchy-system-lock` from the old layout — applying it as-is would **delete the symlink** and detach the home dir from the package (breaking themes/defaults/migrations). This must be removed from chezmoi source. The custom brightness-off-after-lock behavior it provided has **no replacement** in Quattro's new `/usr/share/omarchy/bin/omarchy-system-lock` (which delegates to `omarchy-shell lock lock` instead) — confirmed acceptable to lose (user's call).
- `elephant`, `walker`, `waybar` packages/binaries no longer exist anywhere on the system (confirmed via `pacman -Qi` and `command -v`). Quattro's quickshell already ships its own `background`/`image-picker` plugins (`/usr/share/omarchy/shell/plugins/background`, `/plugins/image-picker`), fully superseding your old elephant background-selector Lua menu. Drop all three from chezmoi tracking.
- `~/.config/omarchy/hooks/theme-set` (chezmoi-tracked, unchanged by the upgrade) still has a block that copies a stylesheet into `~/.config/walker/themes/gruvbox/style.css` and calls `omarchy-restart-walker`. Once walker's config is deleted, remove this block — quickshell's `Color.qml` reads theme colors from the theme files directly and needs no restart-on-theme-change step.
- `kitty.conf`'s `include` path and the (now-inert) `hyprland.conf`'s `source` line both point at a stale `~/.config/omarchy/current/theme/...` path from an old commit; the real current-theme location in Quattro is `~/.local/state/omarchy/current/...` (verified: real symlink farm with `theme/`, `theme.name`, `background`; `~/.config/omarchy/current` doesn't exist). `kitty.conf` is a real terminal config kitty reads directly — its path must be fixed. `hyprland.conf`'s copy of this bug is moot since the file is being retired entirely (see below).
- `mimeapps.list`: restore the chezmoi-tracked associations (chromium.desktop, HEY.desktop for mail) over the fresh-install defaults (confirmed).
- Age key (`~/.config/chezmoi/key.txt`) missing post-reinstall; no `encrypted_*` files currently tracked, so this is a non-blocking follow-up only.
- `hypridle.conf` (separate daemon, its own `.conf` format, unaffected by the Hyprland Lua switch) already matches chezmoi source exactly — no action needed.
- No ADRs requested for the bar-stack removal or the conf→lua migration (personal dotfiles repo; commit messages + this plan are enough).

**Keybinding preference decisions** (confirmed with user — Quattro's new defaults reassigned several keys the old config had customized; user chose to keep old muscle memory in every case):
- Keep the old O=togglesplit / F=pop-window-out mapping (re-add unbind+rebind for O and F; Quattro's new default of J=togglesplit/O=pop-out/F=fullscreen is not adopted).
- Keep SUPER+C/V/X inert (re-add the unbinds; don't adopt Quattro's new "universal copy/cut/paste" feature on those keys).
- Keep the clipboard manager on SUPER+CTRL+H, but repoint its command from the dead `omarchy-launch-walker -m clipboard` to the new native `omarchy-shell shell toggle omarchy.clipboard`. SUPER+CTRL+V stays free of the new default's clipboard-manager binding.
- Keep SUPER+CTRL+SPACE bound to "Omarchy menu" (`omarchy-menu`), overriding Quattro's new default use of that combo for the background switcher.
- Keep SUPER+SHIFT+SPACE unbound/inert (re-add the unbind), overriding Quattro's new default of toggling quickshell's top bar on that combo.
- `kb_options`: strip back to `"compose:caps"` only, dropping Quattro's new default addition of `shift:both_capslock_cancel`.

**Lua syntax research** (confirmed via Hyprland's own example config at github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua, the community API reference at alejandrominaya.github.io/hyprland-lua-docs, and hypr.land/news/26_lua — the official wiki's Lua pages are JS-rendered and didn't return content via WebFetch; worth a final sanity-check on first `hyprctl reload` but reasonably confident):
- Window rule negation: prefix the match value with `negative:`, e.g. `match = { class = "negative:^(steam)$" }` — this is Hyprland's core windowrule matching syntax (also used as-is in the old `.conf`), not Lua-specific, so it passes through `hl.window_rule`'s match table unchanged.
- Per-device config: standalone `hl.device({ name = "...", sensitivity = ... })` call (not nested under `hl.config`).
- Gestures: standalone `hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })` call.
- Monitors: standalone `hl.monitor({ output = "...", mode = "...", position = "...", scale = ... })` call, one per monitor, cumulative.
- Animations: two-part API — `hl.curve(name, { type = "bezier", points = {...} })` defines a named curve, then `hl.animation({ leaf = "...", enabled = true, speed = ..., bezier = "curvename", style = "..." })` applies it per leaf (e.g. `"workspaces"`, `"windowsMove"`). Omarchy's defaults likely already register an `"easeOutQuint"` curve globally (it was the stock animation curve in the old `.conf` too) — reference it by name first; only add a fresh `hl.curve("easeOutQuint", {...})` if `hyprctl reload` errors with an unknown-curve message.

## Plan

### 1. Do this work on a new `quatro` branch
Before touching anything, create and switch to a new branch in the chezmoi repo so the Quattro migration is isolated from `main` until it's verified working:
```bash
cd ~/.local/share/chezmoi
git checkout -b quatro
```
Every subsequent step (removals, new/edited tracked files) happens as commits on `quatro`. All customizations ported in this plan must end up committed to the chezmoi repo — nothing should exist only on disk. Leave the merge back to `main` for the user to do explicitly once verification (step 9) passes.

### 2. Drop obsolete chezmoi-tracked entries
`git rm -r` inside `~/.local/share/chezmoi`:
- `private_dot_config/elephant/`
- `private_dot_config/walker/`
- `private_dot_config/waybar/`
- `private_dot_local/private_share/omarchy/` (the system-lock override — obsolete and dangerous, see above)

### 3. Retire the dead Hyprland `.conf` tracking, replace with `.lua`
Remove from chezmoi source (superseded by step 4): `private_dot_config/hypr/hyprland.conf`, `bindings.conf`, `looknfeel.conf`, `input.conf`, `autostart.conf`, `envs.conf`, `windows.conf`. `monitors.conf` was never chezmoi-tracked (machine-specific, nwg-displays-generated) — leave that convention as-is for `monitors.lua` too (write it locally, don't track it).

Newly track (plain files, same as the `.conf` files were — not `executable_`): `private_dot_config/hypr/hyprland.lua`, `bindings.lua`, `looknfeel.lua`, `input.lua`, `autostart.lua`, `envs.lua`, `windows.lua`.

### 4. Port each `.conf` to `.lua`

**`hyprland.lua`** — add two `require()` lines (currently missing) so personal envs/windows overrides actually load, following the existing pattern (loaded after Omarchy's defaults so they can override):
```lua
require("hypr.envs")
require("hypr.windows")
```

**`envs.lua`** (new) — only what Quattro's own `default/hypr/envs.lua` doesn't already set (it already sets `XCURSOR_SIZE=24`, `HYPRCURSOR_SIZE=24`, all the Wayland/QT/Electron platform vars — no need to duplicate those):
```lua
hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")
hl.env("XCURSOR_THEME", "Caiptain-Gruvbox")
hl.env("XCURSOR_SIZE", "34")
hl.env("HYPRCURSOR_THEME", "Caiptain-Gruvbox")
hl.env("HYPRCURSOR_SIZE", "34")
```

**`looknfeel.lua`** — port `general`/`decoration`/`layout` via `hl.config()`; port `animations` via `hl.animation()` (see syntax note above — not nested inside `hl.config`):
```lua
hl.config({
  general = { gaps_in = 4, gaps_out = 8, border_size = 3, no_focus_fallback = true },
  decoration = { rounding = 4, rounding_power = 4.0 },
  layout = { single_window_aspect_ratio = { 4, 3 } },
})

hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "easeOutQuint" })
```

**`autostart.lua`** — direct port via `o.launch_on_start` (confirmed helper: wraps `uwsm-app -- <cmd>`, matching the old `uwsm app -- <cmd>` convention):
```lua
o.launch_on_start("bash -c 'SSH_ASKPASS=~/.local/bin/ssh-askpass-keyring SSH_ASKPASS_REQUIRE=prefer ssh-add ~/.ssh/richard_ed25519'")
o.launch_on_start("udiskie --tray")
```

**`input.lua`** — much of the old `input.conf` is now redundant with Quattro's new default (`repeat_rate=40` and `scroll_factor=0.4` already match; the two terminal `scroll_touchpad` window rules for Alacritty/kitty/ghostty are **already in the default** — don't re-add them). Only the real deltas need porting:
```lua
hl.config({
  input = {
    kb_options = "compose:caps",               -- stripped back per user preference; drops default's added shift:both_capslock_cancel
    repeat_delay = 600,                         -- default is 250
    touchpad = { natural_scroll = true },       -- default is false
    disable_while_typing = true,                -- not set by default
  },
})

hl.device({ name = "logitech-mx-ergo-1", sensitivity = -0.3 })
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

**`windows.lua`** — port using `o.window(match, rules)` (confirmed API: `match` can be a class-string or a table of `class`/`title`/`xwayland`/etc.; `rules` is a table of windowrule-verb → value):
```lua
o.window("^(Bluetooth Devices)$", { no_screen_share = true, tag = "+floating-window" })

-- Steam fixes
o.window({ class = "^(steam)$", title = "^(Steam)$" }, { float = false, tile = true })
o.window({ class = "^(steam)$", title = "^(Friends List|Settings|Properties)$" }, { float = true })

-- Game fixes (excluding Steam)
o.window({ xwayland = true }, { opacity = "1.0 override 1.0 override" })
o.window({ xwayland = true, class = "negative:^(steam)$" }, { fullscreen = true })
```

**`monitors.lua`** (local only, not chezmoi-tracked — hand-port the two lines from the nwg-displays-generated `monitors.conf`, using the confirmed `hl.monitor()` API):
```lua
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "DP-3", mode = "3440x1440@120.0", position = "280x0", scale = 1.0 })
```
Before hand-writing, worth trying `nwg-displays` again in case this system's 0.4.3 copy now emits `monitors.lua` directly — check its output path before assuming it still writes `.conf`.

### 5. Port `bindings.lua`

Quattro's new default bindings (`/usr/share/omarchy/default/hypr/bindings/{applications,tiling,clipboard,media,voxtype}.lua`) reassigned several keys your old config had customized. Per the confirmed decisions above, every conflict is resolved as "keep the old behavior" — so this is now a mechanical port (unbind the new default, rebind to the old action), just with four specific unbind/rebind pairs that didn't exist in the old config's literal form because the *reason* for unbinding has changed:

```lua
-- Old scheme: O=togglesplit, F=pop-window-out (Quattro defaults these to J=togglesplit, O=pop-out, F=fullscreen)
hl.unbind("SUPER + O")   -- was: pop-window-out
hl.unbind("SUPER + F")   -- was: fullscreen
o.bind("SUPER + O", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + F", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")
-- SUPER+J keeps Quattro's default (togglesplit) unbound from J is NOT needed here since
-- you're not using J for anything custom -- leave J's default as-is (redundant with O, harmless).
-- SUPER+M (fullscreenstate / maximize) had no default conflict -- port as before.

-- Old: SUPER+C/V/X inert
hl.unbind("SUPER + C")
hl.unbind("SUPER + V")
hl.unbind("SUPER + X")

-- Old: SUPER+CTRL+H clipboard manager, now pointed at the native command (walker is gone)
hl.unbind("SUPER + CTRL + H")
o.bind("SUPER + CTRL + H", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")
-- Leave the new default's SUPER+CTRL+V clipboard-manager binding unbound/untouched --
-- decide separately if you want it free or also pointed at the same command.

-- Old: SUPER+CTRL+SPACE = Omarchy menu (overrides the new default's background-switcher use of this combo)
hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + SPACE", "Omarchy menu", "omarchy-menu")

-- Old: SUPER+SHIFT+SPACE stays inert (overrides the new default's top-bar toggle)
hl.unbind("SUPER + SHIFT + SPACE")
```

Remaining bindings port as straightforward `o.bind`/`hl.unbind` translations with no default conflicts found (mods joined with `+` instead of spaces, e.g. `$meta_mod` → `"SUPER + CTRL"`): `SUPER+CTRL+D` capture menu, `SUPER+ALT+T` theme toggle, `SUPER+CTRL+T` terminal, `CTRL+SHIFT+ESCAPE` activity/btop, `SUPER+CTRL+B` browser, `SUPER+CTRL+C`/`SUPER+CTRL+E` calendar/email webapps, vim-style focus/move on N/I/U/E and SHIFT+N/I/U/E, bracket-key workspace switching (`[`/`]`, plain and ALT), `SUPER+CTRL+SHIFT+1..0` silent move-to-workspace, `SUPER+CTRL+ALT+N/I/U/E` resize, `ALT+`/`CTRL+ALT+`+`mouse:272` drag/resize, `SUPER+CTRL+ALT+D` laptop-display toggle, side-mouse-button workspace scroll, and the `F9` voxtype unbind.

Test live with `hyprctl reload` after writing this file — confirm each of the five resolved-conflict bindings above actually does what's intended and doesn't silently fall through to a still-active default.

### 6. Clean the `theme-set` hook
In `~/.local/share/chezmoi/private_dot_config/omarchy/hooks/executable_theme-set`, remove the block that does:
```bash
WALKER_GRUVBOX_DIR="$HOME/.config/walker/themes/gruvbox"
if [[ "$THEME_NAME" == "gruvbox" ]]; then
  cp "$WALKER_GRUVBOX_DIR/style-dark.css" "$WALKER_GRUVBOX_DIR/style.css"
else
  cp "$WALKER_GRUVBOX_DIR/style-dynamic.css" "$WALKER_GRUVBOX_DIR/style.css"
fi
"$HOME/.local/share/omarchy/bin/omarchy-restart-walker" >/dev/null 2>&1
```
No replacement needed — quickshell re-reads theme colors from the theme files directly.

### 7. Fix `kitty.conf`'s theme path
```
-include ~/.config/omarchy/current/theme/kitty.conf
+include ~/.local/state/omarchy/current/theme/kitty.conf
```

### 8. Commit, then apply
Every file touched in steps 2–7 lives in the chezmoi source dir (`~/.local/share/chezmoi`) — `git add` and `git commit` them on the `quatro` branch so the customizations persist in the repo, not just on disk. Then run `chezmoi apply -v` (interactive terminal, not backgrounded — it may prompt) to push the source state out to the live system. This restores what the upgrade wiped but chezmoi still tracks correctly:
- `mise/config.toml`: `codex`, `claude`, `gh` tools
- `gtk-3.0/bookmarks`: labeled Downloads/Projects/Pictures/Videos entries
- `hypr/hyprsunset.conf`: explanatory comment block (hyprsunset is a separate daemon, unaffected by the Lua switch)
- `mimeapps.list`: chromium/HEY associations
- the new `.lua` files and edited `theme-set`/`kitty.conf` from steps 2–7

### 9. Verify
- `chezmoi status` / `chezmoi diff` → clean.
- `git log --stat` on `quatro` → every removal and new/edited file from steps 2–7 shows up as a commit.
- `hyprctl reload` → no config errors; `hyprctl systeminfo | grep configProvider` still `lua`.
- Walk through every binding in section 5's resolved-conflict list live, confirm each does what you now want.
- New kitty window picks up theme colors correctly (confirms the path fix).
- `omarchy theme set gruvbox` (or the light variant) runs cleanly with no stderr from the removed walker block, and quickshell's colors update.
- `ls -la ~/.local/share/omarchy` → still a symlink to `/usr/share/omarchy` with full contents (confirms step 2 didn't detach it).
- `pgrep -fal quickshell` → still the only bar/launcher process; no waybar/walker/mako/swayosd processes.

### Follow-ups (not part of this pass)
- Age key (`~/.config/chezmoi/key.txt`) — restore from backup when convenient; nothing currently depends on it.
- Once verification passes, merge `quatro` back into `main` (or rebase/fast-forward, per your usual convention) — left for you to do explicitly, not done automatically by this pass.
- Whether SUPER+CTRL+V (the new default's clipboard-manager key) should also point at the same clipboard command as SUPER+CTRL+H, or stay free — noted inline above as an open detail, not blocking.
