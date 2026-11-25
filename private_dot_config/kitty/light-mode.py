# Loaded by `geninclude` in kitty.conf on every config load, so the
# theme-set hook's `kitty @ load-config` switches it with the theme.
# Dark text on a light background looks thin and washed out with the
# ExtraLight weight that suits dark mode, so light mode gets a heavier
# weight, a darker foreground and kitty's dark-on-light gamma boost.
from pathlib import Path

if (Path.home() / ".local/state/omarchy/current/theme/light.mode").exists():
    print('font_family family="JetBrains Mono" style="Regular" features="cv07=1 cv08=1"')
    print("text_composition_strategy 1.7 30")
    print("foreground #1d2021")
