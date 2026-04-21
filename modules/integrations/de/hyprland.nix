# Hyprland integration config generator for ft-nixpalette.
# Generates color variable declarations that Hyprland can source directly.
# No Hyprland package dependency — assumes Hyprland is already installed.
{ lib, resolvedTheme, ... }:

let
  b16 = resolvedTheme.base16;

  slots = [
    "base00" "base01" "base02" "base03"
    "base04" "base05" "base06" "base07"
    "base08" "base09" "base0A" "base0B"
    "base0C" "base0D" "base0E" "base0F"
  ];

  # Hyprland color variable declarations.
  # Source in hyprland.conf:
  #   source = ~/.config/hypr/ft-nixpalette-colors.conf   (Home Manager)
  #   source = /etc/ft-nixpalette/hyprland/colors.conf     (NixOS)
  # Then reference anywhere: col.active_border = $ft_base0D
  colorVarsText =
    "# ft-nixpalette: generated, do not edit\n"
    + lib.concatMapStrings (s: "$ft_${s} = rgb(${b16.${s}})\n") slots;

in
{
  nixosConfig = {
    environment.etc."ft-nixpalette/hyprland/colors.conf".text = colorVarsText;
  };

  hmConfig = {
    xdg.configFile."hypr/ft-nixpalette-colors.conf".text = colorVarsText;
  };
}
