# This file replaces $OMARCHY_PATH/default/themed/kitty.conf.tpl wholesale
# (user templates in ~/.config/omarchy/themed/ win over the built-in one), so
# it must restate every key the stock template sets.

# Jetbrains Mono weight is theme-specific (see font_weight/italic_weight in
# each theme's colors.toml); bold weights don't vary, so stay fixed here.
font_family family="Jetbrains Mono" style="{{ font_weight }}" features="cv07=1 cv08=1"
italic_font family="Jetbrains Mono" style="{{ italic_weight }}" features="ss02=1 cv08=1 cv12=1"
bold_font family="Jetbrains Mono" style="SemiBold" features="cv07=1 cv08=1 cv12=1"
bold_italic_font family="Jetbrains Mono" style="SemiBold Italic" features="ss02=1 cv08=1"

foreground {{ foreground }}
background {{ background }}
selection_foreground {{ selection_foreground }}
selection_background {{ selection_background }}

cursor {{ bright_foreground }}
cursor_text_color {{ background }}

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
