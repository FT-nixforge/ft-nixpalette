{ lib }:

let
  loader   = import ./loader.nix   { inherit lib; };
  resolver = import ./resolver.nix { inherit lib; };
in
{
  inherit (loader)   loadThemesFromRoot loadAllThemes;
  inherit (resolver) resolve;
}
