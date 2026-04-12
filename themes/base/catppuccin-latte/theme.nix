# Catppuccin Latte — the light variant of the Catppuccin palette.
# https://catppuccin.com
{
  polarity = "light";

  base16 = {
    base00 = "eff1f5"; # Base
    base01 = "e6e9ef"; # Mantle
    base02 = "ccd0da"; # Surface0
    base03 = "bcc0cc"; # Surface1
    base04 = "acb0be"; # Surface2
    base05 = "4c4f69"; # Text
    base06 = "dc8a78"; # Rosewater
    base07 = "7287fd"; # Lavender
    base08 = "d20f39"; # Red
    base09 = "fe640b"; # Peach
    base0A = "df8e1d"; # Yellow
    base0B = "40a02b"; # Green
    base0C = "179299"; # Teal
    base0D = "1e66f5"; # Blue
    base0E = "8839ef"; # Mauve
    base0F = "dd7878"; # Flamingo
  };

  fonts = {
    serif = {
      name    = "Noto Serif";
      package = "noto-fonts";
    };
    sansSerif = {
      name    = "Inter";
      package = "inter";
    };
    monospace = {
      name    = "JetBrains Mono";
      package = "jetbrains-mono";
    };
    emoji = {
      name    = "Noto Color Emoji";
      package = "noto-fonts-color-emoji";
    };
    sizes = {
      applications = 12;
      desktop      = 11;
      popups       = 10;
      terminal     = 13;
    };
  };

  wallpaper = null;
  overrides = {};
}
