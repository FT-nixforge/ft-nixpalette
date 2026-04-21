# COSMIC Desktop integration config generator for ft-nixpalette.
# Exposes the palette as shell environment variables since COSMIC's theming
# format (libcosmic / Iced-based) is still evolving as of COSMIC alpha.
{ lib, resolvedTheme, ... }:

let
  b16 = resolvedTheme.base16;

  slots = [
    "base00" "base01" "base02" "base03"
    "base04" "base05" "base06" "base07"
    "base08" "base09" "base0A" "base0B"
    "base0C" "base0D" "base0E" "base0F"
  ];

  # Shell env var declarations.
  # Source in COSMIC session scripts or applets:
  #   source ~/.config/cosmic/ft-nixpalette-colors.sh   (Home Manager)
  #   source /etc/ft-nixpalette/cosmic/colors.sh         (NixOS)
  colorVarsText =
    "# ft-nixpalette: generated, do not edit\n"
    + lib.concatMapStrings (s:
        "export FT_${lib.toUpper s}=\"#${b16.${s}}\"\n"
      ) slots;

in
{
  nixosConfig = {
    environment.etc."ft-nixpalette/cosmic/colors.sh".text = colorVarsText;
  };

  hmConfig = {
    xdg.configFile."cosmic/ft-nixpalette-colors.sh".text = colorVarsText;
  };
}
