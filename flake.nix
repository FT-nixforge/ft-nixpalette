{
  description = "ft-nixpalette â€” a reusable NixOS theme framework built on Stylix";

  inputs = {
    nixpkgs.url = "git+ssh://github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "git+ssh://github:danth/stylix";
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
      version      = "1.5.1";
    };
    lib = ftNixpaletteLib;

    # NixOS module (system-wide Stylix + ft-nixpalette)
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
