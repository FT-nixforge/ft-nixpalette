{
  description = "ft-nixpalette — a reusable NixOS theme framework built on Stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, stylix, ... }:
  let
    ftNixpaletteLib  = import ./lib { inherit (nixpkgs) lib; };
    builtinThemesDir = ./themes;
    # Use a flake-root wallpaper image as the default for all themes when present.
    # Evaluates to null if none of the supported filenames exist, triggering the
    # solid-color fallback.
    defaultWallpaper =
      if builtins.pathExists ./wallpaper.png then ./wallpaper.png
      else if builtins.pathExists ./wallpaper.jpg then ./wallpaper.jpg
      else if builtins.pathExists ./wallpaper.jpeg then ./wallpaper.jpeg
      else null;
  in
  {
    meta = {
      name         = "ft-nixpalette";
      type         = "library";
      role         = "standalone";
      description  = "Base16 color theming engine";
      repo         = "github:FT-nixforge/nixpalette";
      provides     = [ "nixosModules" "homeModules" "lib" ];
      dependencies = [];
      status       = "stable";
      version      = "1.0.1";
    };
    lib = ftNixpaletteLib;

    nixosModules.default = {
      imports = [
        stylix.nixosModules.stylix
        (import ./modules/nixos.nix { inherit ftNixpaletteLib builtinThemesDir defaultWallpaper; })
      ];
    };

    homeModules.default = {
      imports = [
        stylix.homeModules.stylix
        (import ./modules/hm.nix { inherit ftNixpaletteLib builtinThemesDir defaultWallpaper; })
      ];
    };
  };
}
