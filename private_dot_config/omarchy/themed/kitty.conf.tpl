# This file replaces $OMARCHY_PATH/default/themed/kitty.conf.tpl wholesale
# (user templates in ~/.config/omarchy/themed/ win over the built-in one), so
# it must restate every key the stock template sets.

foreground {{ foreground }}
background {{ background }}
selection_foreground {{ selection_foreground }}
selection_background {{ selection_background }}

cursor {{ bright_foreground }}
cursor_text_color {{ background }}

# Lets a reload change the background opacity, as Glassy windows do, since
# kitty only allows that when this is on from launch.
dynamic_background_opacity yes

active_border_color {{ accent }}
active_tab_background {{ accent }}

color0 {{ background }}
color1 {{ red }}
color2 {{ green }}
color3 {{ yellow }}
color4 {{ blue }}
color5 {{ magenta }}
color6 {{ cyan }}
color7 {{ foreground }}
color8 {{ muted }}
color9 {{ bright_red }}
color10 {{ bright_green }}
color11 {{ bright_yellow }}
color12 {{ bright_blue }}
color13 {{ bright_magenta }}
color14 {{ bright_cyan }}
color15 {{ bright_foreground }}

# Added on top of the stock template: tab bar and border colors Omarchy
# doesn't theme by default. These used to be hand-pinned to gruvbox-dark's
# hex values directly in kitty.conf, so they stayed dark on every other
# theme (including gruvbox-light). The 8%/15% mixes stand in for "tab bar
# strip" and "inactive tab pill" shades that have no dedicated semantic name.
active_tab_foreground {{ background }}
inactive_tab_foreground {{ muted }}
inactive_tab_background {{ mix background foreground 15% }}
tab_bar_background {{ mix background foreground 8% }}
inactive_border_color {{ muted }}
url_color {{ blue }}
