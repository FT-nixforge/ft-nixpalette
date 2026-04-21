# KDE Plasma integration config generator for ft-nixpalette.
# Generates a KDE color scheme file (.colors) that Plasma can apply directly.
# Install path: ~/.local/share/color-schemes/ft-nixpalette.colors (Home Manager)
{ lib, resolvedTheme, ... }:

let
  b16 = resolvedTheme.base16;

  # Convert a single hex character to its decimal value.
  hexChar = c:
    if c == "0" then 0 else if c == "1" then 1 else if c == "2" then 2
    else if c == "3" then 3 else if c == "4" then 4 else if c == "5" then 5
    else if c == "6" then 6 else if c == "7" then 7 else if c == "8" then 8
    else if c == "9" then 9
    else if c == "a" || c == "A" then 10
    else if c == "b" || c == "B" then 11
    else if c == "c" || c == "C" then 12
    else if c == "d" || c == "D" then 13
    else if c == "e" || c == "E" then 14
    else if c == "f" || c == "F" then 15
    else 0;

  # Convert a 2-character hex string to a decimal integer.
  hexByte = h:
    (hexChar (builtins.substring 0 1 h)) * 16
    + (hexChar (builtins.substring 1 1 h));

  # Produce "R,G,B" decimal string from a 6-character hex color.
  toRgb = hex:
    let
      r = hexByte (builtins.substring 0 2 hex);
      g = hexByte (builtins.substring 2 2 hex);
      b = hexByte (builtins.substring 4 2 hex);
    in "${toString r},${toString g},${toString b}";

  # Convenience aliases for the semantic slots used in the color scheme.
  bg     = toRgb b16.base00;   # window/view background
  bgAlt  = toRgb b16.base01;   # slightly raised surface
  sel    = toRgb b16.base02;   # selection background
  subtle = toRgb b16.base03;   # comments, disabled
  fg4    = toRgb b16.base04;   # dark foreground (light themes)
  fg     = toRgb b16.base05;   # default foreground
  fgBr   = toRgb b16.base06;   # bright foreground
  fgAlt  = toRgb b16.base07;   # light background (contrast)
  red    = toRgb b16.base08;   # errors, removed
  orange = toRgb b16.base09;   # warnings
  yellow = toRgb b16.base0A;   # classes, modified
  green  = toRgb b16.base0B;   # strings, added
  cyan   = toRgb b16.base0C;   # escape sequences
  blue   = toRgb b16.base0D;   # functions, links
  purple = toRgb b16.base0E;   # keywords
  brown  = toRgb b16.base0F;   # deprecated

  # KDE .colors INI file.
  # Drop into ~/.local/share/color-schemes/ and select via
  # System Settings → Colors and Themes → Colors.
  colorsFileText = ''
    [ColorScheme]
    Name=ft-nixpalette

    [Colors:Button]
    BackgroundNormal=${bgAlt}
    BackgroundAlternate=${bg}
    ForegroundNormal=${fg}
    ForegroundInactive=${subtle}
    ForegroundActive=${blue}
    ForegroundLink=${blue}
    ForegroundVisited=${purple}
    ForegroundNegative=${red}
    ForegroundNeutral=${yellow}
    ForegroundPositive=${green}
    DecorationFocus=${blue}
    DecorationHover=${cyan}

    [Colors:Selection]
    BackgroundNormal=${blue}
    BackgroundAlternate=${sel}
    ForegroundNormal=${bg}
    ForegroundInactive=${bgAlt}
    ForegroundActive=${fgBr}
    ForegroundLink=${cyan}
    ForegroundVisited=${purple}
    ForegroundNegative=${red}
    ForegroundNeutral=${yellow}
    ForegroundPositive=${green}
    DecorationFocus=${blue}
    DecorationHover=${cyan}

    [Colors:Tooltip]
    BackgroundNormal=${bgAlt}
    BackgroundAlternate=${bg}
    ForegroundNormal=${fg}
    ForegroundInactive=${subtle}
    ForegroundActive=${blue}
    ForegroundLink=${blue}
    ForegroundVisited=${purple}
    ForegroundNegative=${red}
    ForegroundNeutral=${yellow}
    ForegroundPositive=${green}
    DecorationFocus=${blue}
    DecorationHover=${cyan}

    [Colors:View]
    BackgroundNormal=${bg}
    BackgroundAlternate=${bgAlt}
    ForegroundNormal=${fg}
    ForegroundInactive=${subtle}
    ForegroundActive=${blue}
    ForegroundLink=${blue}
    ForegroundVisited=${purple}
    ForegroundNegative=${red}
    ForegroundNeutral=${yellow}
    ForegroundPositive=${green}
    DecorationFocus=${blue}
    DecorationHover=${cyan}

    [Colors:Window]
    BackgroundNormal=${bgAlt}
    BackgroundAlternate=${bg}
    ForegroundNormal=${fg}
    ForegroundInactive=${subtle}
    ForegroundActive=${blue}
    ForegroundLink=${blue}
    ForegroundVisited=${purple}
    ForegroundNegative=${red}
    ForegroundNeutral=${yellow}
    ForegroundPositive=${green}
    DecorationFocus=${blue}
    DecorationHover=${cyan}

    [Colors:Complementary]
    BackgroundNormal=${sel}
    BackgroundAlternate=${bgAlt}
    ForegroundNormal=${fg}
    ForegroundInactive=${subtle}
    ForegroundActive=${blue}
    ForegroundLink=${blue}
    ForegroundVisited=${purple}
    ForegroundNegative=${red}
    ForegroundNeutral=${yellow}
    ForegroundPositive=${green}
    DecorationFocus=${blue}
    DecorationHover=${cyan}

    [Colors:Header]
    BackgroundNormal=${bgAlt}
    BackgroundAlternate=${bg}
    ForegroundNormal=${fg}
    ForegroundInactive=${subtle}
    ForegroundActive=${blue}
    ForegroundLink=${blue}
    ForegroundVisited=${purple}
    ForegroundNegative=${red}
    ForegroundNeutral=${yellow}
    ForegroundPositive=${green}
    DecorationFocus=${blue}
    DecorationHover=${cyan}

    [WM]
    activeBackground=${bgAlt}
    activeForeground=${fg}
    inactiveBackground=${bg}
    inactiveForeground=${subtle}
    activeBlend=${blue}
    inactiveBlend=${subtle}
  '';

in
{
  nixosConfig = {
    environment.etc."ft-nixpalette/kde/ft-nixpalette.colors".text = colorsFileText;
  };

  hmConfig = {
    xdg.dataFile."color-schemes/ft-nixpalette.colors".text = colorsFileText;
  };
}
