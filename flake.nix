{
  description = "nixpalette — a reusable NixOS theme framework built on Stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, stylix, ... }:
  let
    nixpaletteLib = import ./lib { inherit (nixpkgs) lib; };
    builtinThemesDir = ./themes;
  in
  {
    lib = nixpaletteLib;

    nixosModules.default = {
      imports = [
        stylix.nixosModules.stylix
        (import ./modules/nixos.nix { inherit nixpaletteLib builtinThemesDir; })
      ];
    };

    homeManagerModules.default = {
      imports = [
        stylix.homeManagerModules.stylix
        (import ./modules/hm.nix { inherit nixpaletteLib builtinThemesDir; })
      ];
    };
  };
}
