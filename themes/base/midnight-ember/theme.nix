# Midnight Ember — a deep charcoal dark theme with warm amber and ember accents.
#
# This file demonstrates every available field in a base theme.
# Fields marked "optional" can be omitted — ft-nixpalette will use sensible defaults.
# Fields marked "required" must be present in every base theme.
{
  # ─── Polarity ────────────────────────────────────────────────────────────────
  # Required. Tells Stylix whether this is a dark or light theme.
  # Used to configure applications that adapt their chrome to the scheme polarity.
  # Accepted values: "dark" | "light"
  polarity = "dark";

  # ─── Base16 Palette ──────────────────────────────────────────────────────────
  # Required. All 16 slots must be present. Values are lowercase hex strings
  # WITHOUT a leading '#'. Follow the base16 semantic conventions:
  #
  #   base00  Default background
  #   base01  Lighter background  (status bars, line highlight, gutter)
  #   base02  Selection / highlighted background
  #   base03  Comments, invisibles, line numbers
  #   base04  Dark foreground     (used in status bars)
  #   base05  Default foreground, caret, delimiters
  #   base06  Light foreground    (not often used)
  #   base07  Light background    (not often used — e.g. light-on-dark popups)
  #   base08  Variables, XML tags, markup link text              — red family
  #   base09  Integers, booleans, constants, embedded language   — orange family
  #   base0A  Classes, bold text, search text highlight          — yellow family
  #   base0B  Strings, inherited class, markup code blocks       — green family
  #   base0C  Support, regular expressions, escape characters    — cyan family
  #   base0D  Functions, methods, attribute IDs, headings        — blue family
  #   base0E  Keywords, storage, selectors, markup italic        — purple family
  #   base0F  Deprecated, opening/closing embedded language tags — brown/red
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

  # ─── Fonts ───────────────────────────────────────────────────────────────────
  # Optional. When omitted, Stylix uses its own default fonts.
  # Each role (serif, sansSerif, monospace, emoji) takes:
  #   name    — the font family name as a string (used by Stylix / fontconfig)
  #   package — nixpkgs attribute path as a string.
  #             Supports dot-separated paths for nested attrs:
  #               "inter"                      → pkgs.inter
  #               "nerd-fonts.jetbrains-mono"  → pkgs.nerd-fonts.jetbrains-mono
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

    # Optional. Individual sizes can be omitted; these are the defaults.
    sizes = {
      applications = 12; # General application UI font size (pt)
      desktop      = 11; # Desktop environment UI (panels, docks) (pt)
      popups       = 10; # Tooltips, notifications, context menus (pt)
      terminal     = 13; # Terminal emulator font size (pt)
    };
  };

  # ─── Cursor ──────────────────────────────────────────────────────────────────
  # Optional. You can set just the size, or also name/package when you want the
  # theme to ship a specific cursor family through Stylix.
  cursor = {
    name    = "Bibata-Modern-Classic";
    package = "bibata-cursors";
    size    = 24;
  };

  # ─── Opacity ─────────────────────────────────────────────────────────────────
  # Optional. These values map directly to Stylix's opacity settings.
  opacity = {
    applications = 0.96;
    desktop      = 1.0;
    popups       = 0.98;
    terminal     = 0.93;
  };

  # ─── Wallpaper ───────────────────────────────────────────────────────────────
  # Optional. Path to a wallpaper image file to ship with the theme.
  # Use a path relative to this file, e.g.:  wallpaper = ./wallpaper.png;
  # When null, ft-nixpalette auto-generates a solid-color wallpaper from base00
  # using ImageMagick at build time. Stylix's image option is always satisfied.
  wallpaper = ./default.jpg;

  # ─── Extra Stylix Overrides ──────────────────────────────────────────────────
  # Optional. Any values here are merged on top of the theme defaults, but still
  # remain lower priority than "ft-nixpalette".stylixOverrides or direct stylix.*.
  overrides = {};
}
