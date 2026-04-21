# DE integration option declarations.
# Imported by both nixos.nix and hm.nix as:
#   options."ft-nixpalette".integrations = import ./integrations/de/default.nix { inherit lib; };
{ lib }:

{
  de = lib.mkOption {
    type        = lib.types.nullOr (lib.types.enum [
      "Hyprland"
      "MangoWC"
      "Niri"
      "GNOME"
      "KDE"
      "COSMIC"
    ]);
    default     = null;
    description = ''
      Desktop environment or window manager to integrate with.
      When set, ft-nixpalette generates DE-specific color variable files
      derived from the active palette.

      Supported values:
        "Hyprland" — Hyprland color variables ($ft_baseXX = rgb(...))
        "MangoWC"  — MangoWC color variables ($ft_baseXX = rgb(...))
        "Niri"     — shell environment variables (export FT_BASE_XX="#...")
        "GNOME"    — GTK4 CSS custom properties (--ft-baseXX: #...)
        "KDE"      — KDE Plasma color scheme (.colors file)
        "COSMIC"   — shell environment variables (export FT_BASE_XX="#...")

      Set to null (default) to disable all DE integration.
    '';
    example = "Hyprland";
  };
}
