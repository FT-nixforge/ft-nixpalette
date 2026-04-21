# GNOME integration config generator for ft-nixpalette.
# Generates a GTK4 CSS custom properties file exposing the active palette.
# Import it from your gtk.css to use var(--ft-base0D) etc. in app stylesheets.
{ lib, resolvedTheme, ... }:

let
  b16 = resolvedTheme.base16;

  slots = [
    "base00" "base01" "base02" "base03"
    "base04" "base05" "base06" "base07"
    "base08" "base09" "base0A" "base0B"
    "base0C" "base0D" "base0E" "base0F"
  ];

  # GTK4 CSS custom properties.
  # Import from ~/.config/gtk-4.0/gtk.css:
  #   @import 'ft-nixpalette-colors.css';
  # Then reference: color: var(--ft-base0D);
  colorVarsText =
    "/* ft-nixpalette: generated, do not edit */\n"
    + ":root {\n"
    + lib.concatMapStrings (s: "    --ft-${s}: #${b16.${s}};\n") slots
    + "}\n";

in
{
  nixosConfig = {
    environment.etc."ft-nixpalette/gnome/colors.css".text = colorVarsText;
  };

  hmConfig = {
    xdg.configFile."gtk-4.0/ft-nixpalette-colors.css".text = colorVarsText;
    xdg.configFile."gtk-3.0/ft-nixpalette-colors.css".text = colorVarsText;
  };
}
