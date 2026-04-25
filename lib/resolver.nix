# Theme inheritance resolution.
# Follows the parent chain declared in derived themes, detects cycles,
# and deep-merges parent fields with child overrides.
#
# Every base theme is first merged with themes/default.nix so that omitted
# fields (fonts, cursor, opacity, wallpaper) have sensible defaults.
{ lib }:

let
  # Builtin default values -- merged beneath every base theme.
  defaultTheme = import ../themes/default/theme.nix;

  # Public entry point: resolve a theme ID from the full registry.
  resolve = registry: themeId:
    resolveWithChain registry themeId [];

  # Internal recursive resolver that tracks the visited chain for cycle detection.
  resolveWithChain = registry: themeId: visited:
    if builtins.elem themeId visited then
      builtins.throw (
        "ft-nixpalette: Circular inheritance detected: "
        + lib.concatStringsSep " -> " (visited ++ [ themeId ])
      )
    else if !(registry ? ${themeId}) then
      builtins.throw (
        "ft-nixpalette: Unknown theme '${themeId}'. "
        + "Available themes: ${lib.concatStringsSep ", " (lib.attrNames registry)}"
      )
    else
      let
        entry      = registry.${themeId};
        definition = entry.definition;
        hasParent  = definition ? parent;
      in
      if hasParent then
        let
          parentId       = definition.parent;
          parentResolved = resolveWithChain registry parentId (visited ++ [ themeId ]);
          childFields    = builtins.removeAttrs definition [ "parent" ];
        in
        # Deep merge: parent provides defaults, child overrides selectively.
        lib.recursiveUpdate parentResolved childFields
      else
        # Base theme: merge with global defaults first so every field is defined.
        lib.recursiveUpdate defaultTheme definition;

in
{
  inherit resolve;
}
