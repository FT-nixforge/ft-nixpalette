# Ft-Nixpalette Default Theme
# Deep charcoal dark theme with warm amber and ember accents.
# This theme provides fallback values for all configurable fields.
# When a user theme omits fonts, cursor, opacity, or wallpaper,
# these defaults are used automatically by the resolver.
{
  polarity = "dark";

  base16 = {
    base00 = "1a1a1a"; # Charcoal black   — default background
    base01 = "242424"; # Deep grey        — lighter background
    base02 = "303030"; # Selection grey   — selection / highlights
    base03 = "4a4a42"; # Warm dim grey    — comments, invisibles
    base04 = "7a7a6e"; # Muted warm grey  — status bar foreground
    base05 = "c8c0a8"; # Warm off-white   — default foreground
    base06 = "ddd5c0"; # Light parchment  — light foreground
    base07 = "f2ead8"; # Warm white       — bright highlights
    base08 = "e85d3a"; # Ember red        — variables, errors
    base09 = "f0833a"; # Ember orange     — constants, numbers
    base0A = "e8b84b"; # Amber yellow     — classes, warnings
    base0B = "8fb55e"; # Muted green      — strings, success
    base0C = "7ab8a8"; # Muted teal       — support, regex
    base0D = "7a9fc4"; # Steel blue       — functions, headings
    base0E = "c47ab8"; # Muted mauve      — keywords, storage
    base0F = "a05035"; # Burnt sienna     — deprecated, tags
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

  cursor = {
    name    = "Bibata-Modern-Classic";
    package = "bibata-cursors";
    size    = 24;
  };

  opacity = {
    applications = 0.96;
    desktop      = 1.0;
    popups       = 0.98;
    terminal     = 0.93;
  };

  wallpaper = ./default.jpg;

  overrides = {};
}
