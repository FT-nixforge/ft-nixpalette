{
  description = "ft-nixpalette — a NixOS theme framework built on Stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url  = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, stylix, ... }:
  let
    ftNixpaletteLib  = import ./lib { inherit (nixpkgs) lib; };
    builtinThemesDir = ./themes;
    defaultWallpaper =
      if      builtins.pathExists ./wallpaper.png  then ./wallpaper.png
      else if builtins.pathExists ./wallpaper.jpg  then ./wallpaper.jpg
      else if builtins.pathExists ./wallpaper.jpeg then ./wallpaper.jpeg
      else null;

    modArgs = { inherit ftNixpaletteLib builtinThemesDir defaultWallpaper; };
  in
  {
    meta = {
      name         = "ft-nixpalette";
      type         = "library";
      role         = "standalone";
      description  = "Base16 color theming engine for NixOS";
      repo         = "github:FT-nixforge/ft-nixpalette";
      provides     = [ "nixosModules" "lib" ];
      dependencies = [];
      version      = "2.0.0";
    };

    lib = ftNixpaletteLib;

    nixosModules.default = {
      imports = [
        stylix.nixosModules.stylix
        (import ./modules/nixos.nix modArgs)
      ];
    };
  };
}
