{ lib }:

let
  defaultTheme = import ../themes/default/theme.nix;

  resolve = registry: themeId:
    resolveChain registry themeId [];

  resolveChain = registry: themeId: visited:
    if builtins.elem themeId visited then
      builtins.throw
        "ft-nixpalette: circular inheritance: ${lib.concatStringsSep " -> " (visited ++ [ themeId ])}"
    else if !(registry ? ${themeId}) then
      builtins.throw
        "ft-nixpalette: unknown theme '${themeId}'. Available: ${lib.concatStringsSep ", " (lib.attrNames registry)}"
    else
      let
        entry  = registry.${themeId};
        def    = entry.definition;
      in
      if def ? parent then
        let
          parent     = resolveChain registry def.parent (visited ++ [ themeId ]);
          childFields = builtins.removeAttrs def [ "parent" ];
        in
        lib.recursiveUpdate parent childFields
      else
        lib.recursiveUpdate defaultTheme def;

in
{
  inherit resolve;
}
