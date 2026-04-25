{
  description = "ft-nixpalette â€” a reusable NixOS theme framework built on Stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, stylix, ... }:
  let
    ftNixpaletteLib  = import ./lib { inherit (nixpkgs) lib; };
    builtinThemesDir = ./themes;
    defaultWallpaper =
      if builtins.pathExists ./wallpaper.png then ./wallpaper.png
      else if builtins.pathExists ./wallpaper.jpg then ./wallpaper.jpg
      else if builtins.pathExists ./wallpaper.jpeg then ./wallpaper.jpeg
      else null;

    modArgs = { inherit ftNixpaletteLib builtinThemesDir defaultWallpaper; };
  in
  {
    meta = {
      name         = "ft-nixpalette";
      type         = "library";
      role         = "standalone";
      description  = "Base16 color theming engine";
      repo         = "github:FT-nixforge/nixpalette";
      provides     = [ "nixosModules" "lib" ];
      dependencies = [];
      status       = "unstable";
      version      = "1.5.0";
    };
    lib = ftNixpaletteLib;

    # â”€â”€ NixOS module (system-wide Stylix + ft-nixpalette) â”€â”€
    # This is the ONLY supported way to use ft-nixpalette.
    # It configures Stylix system-wide and provides theme resolution,
    # DE integrations, and specialisations.
    #
    # Home-Manager users get config.lib.stylix.colors automatically
    # via Stylix' own homeManagerIntegration â€” no HM module needed.
    nixosModules.default = {
      imports = [
        stylix.nixosModules.stylix
        (import ./modules/nixos.nix modArgs)
      ];
    };
  };
}
