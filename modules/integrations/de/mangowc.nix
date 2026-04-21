# MangoWC integration config generator for ft-nixpalette.
# Generates color variable declarations in MangoWC compositor format.
{ lib, resolvedTheme, ... }:

let
  b16 = resolvedTheme.base16;

  slots = [
    "base00" "base01" "base02" "base03"
    "base04" "base05" "base06" "base07"
    "base08" "base09" "base0A" "base0B"
    "base0C" "base0D" "base0E" "base0F"
  ];

  # Color variable declarations.
  # Source in mangowc config:
  #   source = ~/.config/mangowc/ft-nixpalette-colors.conf   (Home Manager)
  #   source = /etc/ft-nixpalette/mangowc/colors.conf         (NixOS)
  colorVarsText =
    "# ft-nixpalette: generated, do not edit\n"
    + lib.concatMapStrings (s: "$ft_${s} = rgb(${b16.${s}})\n") slots;

in
{
  nixosConfig = {
    environment.etc."ft-nixpalette/mangowc/colors.conf".text = colorVarsText;
  };

  hmConfig = {
    xdg.configFile."mangowc/ft-nixpalette-colors.conf".text = colorVarsText;
  };
}
