# Niri integration config generator for ft-nixpalette.
# Niri's KDL config has no variable system, so colors are exposed as
# shell environment variables that scripts, bars, and launchers can consume.
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
  # Source before starting niri or in bar/launcher scripts:
  #   source ~/.config/niri/ft-nixpalette-colors.sh   (Home Manager)
  #   source /etc/ft-nixpalette/niri/colors.sh         (NixOS)
  colorVarsText =
    "# ft-nixpalette: generated, do not edit\n"
    + lib.concatMapStrings (s:
        "export FT_${lib.toUpper s}=\"#${b16.${s}}\"\n"
      ) slots;

in
{
  nixosConfig = {
    environment.etc."ft-nixpalette/niri/colors.sh".text = colorVarsText;
  };

  hmConfig = {
    xdg.configFile."niri/ft-nixpalette-colors.sh".text = colorVarsText;
  };
}
